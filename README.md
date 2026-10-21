# Customer Contract Intelligence — Snowflake Cortex AI
Portfolio demonstration | SQL · Snowflake Cortex AI · Contract Analytics

Turn raw customer contract text into structured commercial insights for Customer Success and Account Management teams.
What this project demonstrates
- AI_EXTRACT: extract commercial terms, discounts, dates, notice periods, obligations and source evidence from unstructured contract text.
- AI_CLASSIFY: classify how negotiated discounts apply at renewal.
- AI_COMPLETE: generate evidence-grounded renewal actions and identify ambiguities requiring review.
- Standard SQL: type conversion, notice deadline calculations, discount analysis, review flags and dashboard-ready views.
- Traceability: retain CONTRACT_RAW_TEXT, clause excerpts and extraction scores for verification.
Files
- snowflake_contract_intelligence.sql — end-to-end example pipeline.
- raw_contract_documents_100.csv — input: 100 synthetic contract documents with raw text.
- customer_contract_360_100.csv — independently simulated illustrative dashboard dataset, not the output of a Cortex run.
- contract_clauses_700.csv — independently simulated clause reference data, not the output of a Cortex run.
How to run
1. In Snowsight, select a warehouse and a role with SNOWFLAKE.CORTEX_USER.
2. Open the SQL script and run the database/schema/stage/file-format/table creation statements.
3. Upload raw_contract_documents_100.csv to @CONTRACT_CSV_STAGE without compression, keeping the filename.
4. Run the COPY INTO and row-count validation statements.
5. Run the Cortex extraction statements with SAMPLE_LIMIT = 5 first to check results and cost.
6. Inspect AI_RESULT:response, AI_RESULT:scoring, and source evidence before expanding to all 100 documents.
7. Set SAMPLE_LIMIT = 100 and rerun the AI extraction and downstream statements when satisfied.
8. Query CUSTOMER_CONTRACT_360 for the dashboard-ready output.
Note: Re-running CREATE OR REPLACE TABLE overwrites derived tables. Cortex AI calls consume credits. Availability and supported models vary by region and account permissions.
Data provenance
All customer names, contract clauses, amounts and business scenarios are fictional. The source text is generated for portfolio demonstration purposes, and no real customer data is included. The example dashboard dataset was generated independently; it is not evidence of a completed Snowflake Cortex execution.

The SQL is a runnable template based on current Snowflake documentation, but has not been executed in a live Snowflake account. Outputs must be checked against source text, especially where discount and price-uplift terms interact. This is not a legal interpretation engine.
Suggested architecture
RAW_CONTRACT_DOCUMENTS → CONTRACT_AI_EXTRACTIONS → CONTRACT_EXTRACTED_FIELDS → CONTRACT_AI_CLASSIFICATIONS + CONTRACT_AI_INSIGHTS → CUSTOMER_CONTRACT_360

CRM, billing, support and product usage metrics can later be joined to the contract-derived fields. These enrichment metrics are not represented as AI-extracted contract facts.
References
- https://docs.snowflake.com/en/sql-reference/functions/ai_extract
- https://docs.snowflake.com/en/sql-reference/functions/ai_classify
- https://docs.snowflake.com/en/sql-reference/functions/ai_complete-single-string
- https://docs.snowflake.com/en/user-guide/snowflake-cortex/parse-document
