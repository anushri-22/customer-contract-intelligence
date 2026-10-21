-- CUSTOMER CONTRACT INTELLIGENCE | Snowflake Cortex AI
-- Portfolio demo. Uses 100 SYNTHETIC contracts, not actual customer agreements.
-- Source: raw_contract_documents_100.csv (9 columns, including CONTRACT_RAW_TEXT).
-- Run in Snowsight after uploading the CSV to @CONTRACT_CSV_STAGE.
-- AI inference incurs Snowflake credits. Test with SAMPLE_LIMIT = 5 first.
-- Requires a role with SNOWFLAKE.CORTEX_USER; an existing warehouse.
--
-- IMPORTANT: AI outputs are evidence candidates, not legal conclusions.
-- This pipeline actually calls Cortex AI; the companion dashboard CSV contains
-- independently simulated example outputs and is NOT proof of Cortex execution.

CREATE DATABASE IF NOT EXISTS CONTRACT_INTELLIGENCE_DEMO;
CREATE SCHEMA IF NOT EXISTS CONTRACT_INTELLIGENCE_DEMO.PUBLIC;
USE DATABASE CONTRACT_INTELLIGENCE_DEMO;
USE SCHEMA PUBLIC;

CREATE OR REPLACE FILE FORMAT CONTRACT_CSV_FORMAT
  TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1 MULTI_LINE = TRUE
  ENCODING = 'UTF8'
  EMPTY_FIELD_AS_NULL = FALSE;

CREATE STAGE IF NOT EXISTS CONTRACT_CSV_STAGE FILE_FORMAT = CONTRACT_CSV_FORMAT;

-- Upload raw_contract_documents_100.csv via Snowsight > Data > Add Data,
-- to the named stage above, or SnowSQL:
-- PUT file:///absolute/path/raw_contract_documents_100.csv
--   @CONTRACT_CSV_STAGE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

CREATE OR REPLACE TABLE RAW_CONTRACT_DOCUMENTS (
    DOCUMENT_ID VARCHAR,
    CUSTOMER_ID VARCHAR,
    CONTRACT_ID VARCHAR,
    DOCUMENT_TYPE VARCHAR,
    SOURCE_FILE_NAME VARCHAR,
    CONTRACT_RAW_TEXT VARCHAR,
    EXTRACTION_STATUS VARCHAR,
    PROCESSED_AT TIMESTAMP_NTZ,
    TEXT_LENGTH NUMBER
);

COPY INTO RAW_CONTRACT_DOCUMENTS
FROM @CONTRACT_CSV_STAGE/raw_contract_documents_100.csv
FILE_FORMAT = (FORMAT_NAME = CONTRACT_CSV_FORMAT)
ON_ERROR = 'ABORT_STATEMENT';

SELECT COUNT(*) AS CONTRACTS_LOADED,
       COUNT_IF(CONTRACT_RAW_TEXT IS NOT NULL) AS WITH_RAW_TEXT
FROM RAW_CONTRACT_DOCUMENTS;

-- Optional real PDF ingestion (not required for the supplied CSV).
-- Place PDF files in a separate stage; AI_PARSE_DOCUMENT supports OCR/LAYOUT.
-- SELECT AI_PARSE_DOCUMENT(
--     TO_FILE('@CONTRACT_PDF_STAGE', 'contract_001.pdf'),
--     {'mode': 'OCR'}
-- ):content::VARCHAR AS CONTRACT_RAW_TEXT;
-- For LAYOUT mode, parse the returned JSON pages/content structure instead.

-- 1. A small reproducible batch. Increase 5 -> 100 after validating.
SET SAMPLE_LIMIT = 5;

CREATE OR REPLACE TABLE CONTRACT_AI_EXTRACTIONS AS
SELECT
    DOCUMENT_ID, CUSTOMER_ID, CONTRACT_ID, SOURCE_FILE_NAME,
    CONTRACT_RAW_TEXT,
    AI_EXTRACT(
      text => CONTRACT_RAW_TEXT,
      responseFormat => {
        'customer_name': 'Exact customer legal name in the agreement',
        'start_date': 'Agreement start date in YYYY-MM-DD format',
        'end_date': 'Agreement expiry date in YYYY-MM-DD format',
        'initial_term_months': 'Initial contracted duration in months, digits only',
        'annual_subscription_fee_gbp': 'Annual subscription fee in GBP, number only',
        'annual_list_price_gbp': 'Undiscounted annual list price in GBP, number only',
        'discount_percent': 'Negotiated subscription discount percentage, number only',
        'discount_type': 'Discount type such as introductory, volume, strategic, or none',
        'discount_reason': 'Explicit commercial reason given for the discount',
        'discount_renewal_treatment': 'Exact wording describing discount treatment on renewal',
        'waived_implementation_fee_gbp': 'Waived implementation fee in GBP, number only; 0 if explicitly none',
        'auto_renewal': 'Whether contract automatically renews: true or false',
        'notice_period_days': 'Notice period in days, digits only',
        'price_uplift_cap_percent': 'Maximum annual price uplift percentage, digits only',
        'termination_rights': 'Contractual termination rights as written',
        'sla_commitments': 'Contractual service level or response time as written',
        'customer_specific_commitment': 'Any bespoke implementation, product, or service commitment',
        'procurement_requirements': 'Purchase order, legal, board or procurement approval requirements',
        'contracted_licenses': 'Number of contracted seats or licences, digits only',
        'contracted_products': 'Names of the products included in this agreement',
        'concession_approver': 'Role of person who approved the commercial concession',
        'discount_evidence': 'Verbatim sentence supporting the discount and renewal treatment',
        'renewal_evidence': 'Verbatim sentence describing renewal and notice',
        'price_uplift_evidence': 'Verbatim sentence describing price uplift restrictions'
      },
      scores => TRUE
    ) AS AI_RESULT,
    CURRENT_TIMESTAMP() AS EXTRACTED_AT
FROM RAW_CONTRACT_DOCUMENTS
ORDER BY DOCUMENT_ID
LIMIT $SAMPLE_LIMIT;

-- Inspect the full response and scores before using extracted fields.
SELECT DOCUMENT_ID, AI_RESULT:response AS EXTRACTED_JSON,
       AI_RESULT:scoring AS EXTRACTION_SCORES,
       AI_RESULT:error AS EXTRACTION_ERROR
FROM CONTRACT_AI_EXTRACTIONS
ORDER BY DOCUMENT_ID;

-- 2. Convert AI-extracted strings to typed SQL columns.
-- TRY_* prevents malformed model values from breaking the pipeline.
CREATE OR REPLACE TABLE CONTRACT_EXTRACTED_FIELDS AS
SELECT
    DOCUMENT_ID, CUSTOMER_ID, CONTRACT_ID, SOURCE_FILE_NAME,
    CONTRACT_RAW_TEXT,
    NULLIF(AI_RESULT:response:customer_name::VARCHAR, '') AS CUSTOMER_NAME,
    TRY_TO_DATE(AI_RESULT:response:start_date::VARCHAR) AS CONTRACT_START_DATE,
    TRY_TO_DATE(AI_RESULT:response:end_date::VARCHAR) AS CONTRACT_END_DATE,
    TRY_TO_NUMBER(AI_RESULT:response:initial_term_months::VARCHAR) AS CONTRACT_DURATION_MONTHS,
    TRY_TO_DECIMAL(AI_RESULT:response:annual_subscription_fee_gbp::VARCHAR, 18, 2) AS CONTRACT_ARR,
    TRY_TO_DECIMAL(AI_RESULT:response:annual_list_price_gbp::VARCHAR, 18, 2) AS LIST_PRICE,
    TRY_TO_DECIMAL(AI_RESULT:response:discount_percent::VARCHAR, 8, 2) AS DISCOUNT_PERCENT,
    AI_RESULT:response:discount_type::VARCHAR AS DISCOUNT_TYPE,
    AI_RESULT:response:discount_reason::VARCHAR AS DISCOUNT_REASON,
    AI_RESULT:response:discount_renewal_treatment::VARCHAR AS DISCOUNT_RENEWAL_TREATMENT,
    TRY_TO_DECIMAL(AI_RESULT:response:waived_implementation_fee_gbp::VARCHAR, 18, 2) AS WAIVED_FEES,
    TRY_TO_BOOLEAN(AI_RESULT:response:auto_renewal::VARCHAR) AS AUTO_RENEWAL_FLAG,
    TRY_TO_NUMBER(AI_RESULT:response:notice_period_days::VARCHAR) AS NOTICE_PERIOD_DAYS,
    TRY_TO_DECIMAL(AI_RESULT:response:price_uplift_cap_percent::VARCHAR, 8, 2) AS PRICE_UPLIFT_CAP_PERCENT,
    AI_RESULT:response:termination_rights::VARCHAR AS EARLY_TERMINATION_RIGHTS,
