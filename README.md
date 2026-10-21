Customer Contract Intelligence
Snowflake Cortex AI · SQL · Customer Success Analytics · Interactive Dashboard

Explore the interactive dashboard ↗
Demo note: This project uses 100 synthetic customer contracts. The dashboard displays illustrative insights; its data was generated independently and is not the output of a completed Snowflake Cortex run. The SQL pipeline is provided for execution and validation in Snowflake.

The problem
Customer Success Managers and Account Executives often have easy access to contract start dates, renewal dates and annual contract values, but important negotiated details are harder to find: temporary discounts, waived fees, renewal notice requirements, price-increase restrictions and bespoke customer commitments. These details can be missed during handovers and renewal preparation.

This project explores how unstructured contract text can become a searchable, evidence-backed commercial intelligence layer.
Live prototype
Open Customer Contract Intelligence Dashboard

The interactive HTML prototype lets you explore:
- 100 synthetic contracts and a portfolio-level overview.
- Customer-specific discounts, concessions, renewal clauses and obligations.
- Renewal risks and potential commercial opportunities.
- Full CONTRACT_RAW_TEXT alongside supporting clause excerpts.
- Illustrative recommended actions for Customer Success and Account Management teams.
The dashboard is a standalone HTML/JavaScript prototype. It does not currently query Snowflake in real time.
Technical approach
PDF / CSV contracts
       |
       v
RAW_CONTRACT_DOCUMENTS (CONTRACT_RAW_TEXT)
       |
       v
Snowflake Cortex AI extraction and classification
       |
       v
SQL type conversion, validation and calculations
       |
       v
CUSTOMER_CONTRACT_360
       |
       v
Interactive dashboard (prototype)
Snowflake functions demonstrated in the SQL
Function / method	Intended role
AI_EXTRACT	Extract contract dates, fees, discount terms, notice periods, pricing caps and supporting evidence from raw text.
AI_CLASSIFY	Categorise discount treatment at renewal.
AI_COMPLETE	Draft a concise, evidence-grounded renewal consideration and recommended next action.
TRY_TO_DATE, TRY_TO_DECIMAL, TRY_TO_NUMBER	Safely convert extracted values into typed fields.
DATEDIFF, DATEADD, CASE, NULLIF	Calculate renewal timing, notice deadlines, discount gaps and review flags.
COPY INTO	Load staged CSV contract text into Snowflake.


For actual PDF ingestion, the pipeline can be extended with AI_PARSE_DOCUMENT. The supplied CSV already includes extracted synthetic contract text, so PDF parsing is not needed to run the current demonstration.
Data
File	Description
raw_contract_documents_100.csv	Input: 100 synthetic documents with full CONTRACT_RAW_TEXT.
customer_contract_360_100.csv	Illustrative 68-column dashboard dataset; not produced by the SQL script.
contract_clauses_700.csv	700 synthetic clause/evidence records.
snowflake_contract_intelligence.sql	Example Snowflake Cortex extraction and transformation pipeline.
index.html	Standalone interactive dashboard for GitHub Pages.


Run the Snowflake pipeline
1. Select a Snowflake warehouse and a role permitted to use Cortex AI functions.
2. Open snowflake_contract_intelligence.sql in Snowsight.
3. Create the database, schema, file format, stage and raw table using the script.
4. Upload raw_contract_documents_100.csv to the stage and run COPY INTO.
5. Run the AI extraction on 5 documents first to inspect output and manage cost.
6. Review the returned JSON, extraction scores and supporting evidence.
7. Expand to all 100 contracts after confirming results.
8. Query the CUSTOMER_CONTRACT_360 view.
Execution status: The SQL has not been validated in a live Snowflake environment as part of this repository's initial build. Snowflake function availability, models and permissions may vary by account and region. AI-generated interpretations should be reviewed against source documents before commercial decisions are made.
Why it matters
The goal is not simply to summarise contracts. It is to help account owners answer three questions before a renewal:
1. What did we agree to? Identify negotiated terms and unusual commitments.
2. What could affect the renewal? Surface discount conditions, deadlines and contractual restrictions.
3. What should we investigate next? Combine extracted evidence with commercial context to prioritise follow-up.
Future improvements
- Connect the dashboard to a live Snowflake-backed application.
- Ingest actual PDFs and amendments using document parsing.
- Add CRM, billing, support and product-usage data to enrich account insights.
- Provide clause-level citations, human review status and amendment precedence checks.
View the live dashboard · Snowflake Cortex AI documentation
