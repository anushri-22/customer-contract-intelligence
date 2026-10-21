# Customer Contract Intelligence

**Snowflake Cortex AI | SQL | Customer Success Analytics | Interactive Dashboard**

### 🚀 [Explore the Live Interactive Dashboard ↗](https://anushri-22.github.io/customer-contract-intelligence/)

An AI-powered contract intelligence project designed to help Customer Success Managers and Account Executives uncover hidden commercial insights, identify renewal risks, and discover revenue opportunities from unstructured customer agreements.

> **Demo note:** This project uses 100 synthetic customer contracts. The interactive dashboard displays illustrative insights generated independently of Snowflake. The SQL pipeline demonstrates how these insights can be extracted using Snowflake Cortex AI, but has not yet been validated through a live Snowflake execution.

---

## The Problem

Customer Success Managers and Account Executives typically have access to basic contract information such as annual recurring revenue (ARR), contract dates and renewal status.

However, commercially significant details are often buried within lengthy agreements, amendments and historical negotiations.

Examples include:

- **Negotiated discounts:** Temporary discounts, special pricing arrangements and their expiry conditions.
- **Commercial concessions:** Waived implementation fees, complimentary services and negotiated exceptions.
- **Renewal obligations:** Notice periods, auto-renewal provisions and termination rights.
- **Pricing restrictions:** Annual price uplift caps and contractual limitations.
- **Customer-specific commitments:** Bespoke integrations, service-level agreements and product commitments.

These details can easily be overlooked during account handovers, QBRs and renewal negotiations, potentially leading to missed revenue opportunities or contractual risks.

**The objective:** Transform unstructured customer contracts into a searchable, evidence-backed commercial intelligence layer that enables account owners to make better renewal decisions.

---

## Live Interactive Dashboard

### [Open Customer Contract Intelligence Dashboard ↗](https://anushri-22.github.io/customer-contract-intelligence/)

The HTML/JavaScript prototype provides an interactive view of 100 synthetic SaaS customer contracts.

**Dashboard capabilities:**

- **Portfolio overview:** View customer contracts, ARR, renewal timelines and commercial risks.
- **Contract intelligence:** Explore negotiated discounts, pricing exceptions, special clauses and customer-specific commitments.
- **Renewal opportunities:** Identify expiring concessions, potential pricing opportunities and renewal considerations.
- **AI-style recommendations:** View illustrative renewal insights and suggested account actions.
- **Contract transparency:** Access the full `CONTRACT_RAW_TEXT` alongside extracted clauses and supporting evidence.
- **Interactive filtering:** Search and explore contracts based on customer-specific commercial attributes.

The current dashboard is a standalone HTML/JavaScript prototype and does not query Snowflake in real time.

---

## Technical Architecture

The project follows a layered data processing approach:

```text
PDF / CSV Customer Contracts
            |
            v
RAW_CONTRACT_DOCUMENTS
(CONTRACT_RAW_TEXT)
            |
            v
Snowflake Cortex AI
AI_EXTRACT | AI_CLASSIFY | AI_COMPLETE
            |
            v
SQL Transformation Layer
Data Validation | Type Conversion
Commercial Calculations
            |
            v
CUSTOMER_CONTRACT_360
            |
            v
Interactive Customer Contract Dashboard
```

### 1. Data Ingestion

Synthetic contract text is loaded into Snowflake using `COPY INTO`.

The `RAW_CONTRACT_DOCUMENTS` table retains the complete original contract text in the `CONTRACT_RAW_TEXT` column.

For actual PDF contracts, the architecture can be extended using `AI_PARSE_DOCUMENT` to convert documents into text before extraction.

### 2. AI-Powered Contract Extraction

Snowflake Cortex AI functions are used in the SQL pipeline to extract and interpret commercially significant contract information.

| Snowflake Function | Application |
|---|---|
| `AI_EXTRACT` | Extract contract dates, subscription fees, discounts, renewal conditions, notice periods and contractual commitments. |
| `AI_CLASSIFY` | Categorise negotiated discount conditions, including whether discounts continue or expire at renewal. |
| `AI_COMPLETE` | Generate evidence-grounded renewal considerations and recommended commercial actions. |
| `AI_PARSE_DOCUMENT` | Proposed extension for processing PDF contracts into machine-readable text. |

**Example extraction:**

Original contract text:

> A 20% introductory discount shall apply to the initial subscription term only. Any subsequent renewal shall be subject to the Supplier's prevailing commercial pricing.

Expected structured output:

```json
{
  "discount_percent": 20,
  "discount_type": "Introductory",
  "discount_renewal_treatment": "Initial term only",
  "renewal_consideration": "Review discount expiry and applicable renewal pricing terms"
}
```

This illustrates how contract language can be converted into structured attributes for commercial analysis.

### 3. SQL Transformations and Commercial Intelligence

Standard Snowflake SQL is used alongside Cortex AI to calculate commercial metrics without unnecessary AI processing.

| SQL Function | Purpose |
|---|---|
| `TRY_TO_DATE` | Convert extracted contract dates into structured date fields. |
| `TRY_TO_DECIMAL` | Convert extracted pricing and discount values into numeric fields. |
| `DATEDIFF` | Calculate days remaining until renewal. |
| `DATEADD` | Calculate contractual notice deadlines. |
| `CASE` | Identify contracts requiring review and categorise renewal timing. |
| `NULLIF` | Handle division-by-zero scenarios in discount calculations. |
| `COPY INTO` | Load staged contract data into Snowflake. |

The resulting `CUSTOMER_CONTRACT_360` view combines extracted commercial attributes, SQL-derived metrics, supporting evidence and AI-generated recommendations.

---

## Dataset

The project includes 100 synthetic customer contracts and a supporting dataset of 700 contractual clauses.

| File | Description |
|---|---|
| `raw_contract_documents_100.csv` | 100 synthetic customer agreements containing complete `CONTRACT_RAW_TEXT`. |
| `customer_contract_360_100.csv` | Illustrative dataset with 68 customer and contract intelligence attributes. |
| `contract_clauses_700.csv` | 700 synthetic contractual clauses with supporting evidence. |
| `snowflake_contract_intelligence.sql` | Snowflake Cortex AI extraction, classification and transformation pipeline. |
| `index.html` | Interactive dashboard hosted through GitHub Pages. |

**Data provenance:** All customer names, financial values, contractual terms and commercial scenarios are fictional. The illustrative dashboard dataset was generated independently and is not the output of the Snowflake SQL pipeline.

---

## Running the Snowflake Pipeline

1. Open Snowflake Snowsight and select a warehouse and role with the required Cortex AI permissions.
2. Open `snowflake_contract_intelligence.sql`.
3. Create the database, schema, file format, stage and raw contract table.
4. Upload `raw_contract_documents_100.csv` to the Snowflake stage.
5. Execute `COPY INTO` to load the raw contract data.
6. Run `AI_EXTRACT` against an initial sample of five contracts.
7. Review the extracted JSON, confidence information where available, and supporting contract evidence.
8. Run the classification and AI-generated insights stages.
9. Expand processing to all 100 contracts after validating the initial results.
10. Query the final `CUSTOMER_CONTRACT_360` view.

**Execution status:** The SQL script is provided as an implementation example and has not yet been validated in a live Snowflake environment. Cortex AI calls may incur usage costs, and supported functions and models may vary by account and region.

---

## Business Value

The project is designed around three questions that Customer Success Managers and Account Executives should be able to answer before a contract renewal.

**1. What did we agree to?**

Identify negotiated pricing, contractual exceptions, bespoke commitments and historical concessions.

**2. What could impact the renewal?**

Surface upcoming notice deadlines, discount expiry conditions, pricing restrictions and contractual obligations.

**3. What should we investigate next?**

Turn extracted contract evidence into commercially relevant follow-up actions, such as validating discount eligibility, reviewing renewal pricing or investigating expansion opportunities.

The objective is to move beyond basic contract storage and enable proactive, data-driven account management.

---

## Future Enhancements

- Connect the interactive dashboard directly to Snowflake using Streamlit.
- Process actual PDF contracts and amendments using `AI_PARSE_DOCUMENT`.
- Integrate CRM, billing, customer support and product usage data.
- Introduce clause-level source citations and amendment precedence validation.
- Implement human-in-the-loop verification for commercially sensitive clauses.
- Build automated renewal risk alerts and commercial opportunity identification.

---

## Tech Stack

**Data Platform:** Snowflake

**AI:** Snowflake Cortex AI (`AI_EXTRACT`, `AI_CLASSIFY`, `AI_COMPLETE`)

**Data Processing:** SQL, CSV ingestion, JSON extraction and transformations

**Frontend:** HTML, CSS, JavaScript

**Deployment:** GitHub Pages

---

### 🔗 Project Links

**[Explore the Interactive Dashboard ↗](https://anushri-22.github.io/customer-contract-intelligence/)**

**[Snowflake Cortex AI Documentation ↗](https://docs.snowflake.com/en/user-guide/snowflake-cortex/aisql)**

---

*Portfolio project demonstrating the application of Snowflake Cortex AI and SQL to customer contract intelligence, commercial analytics and SaaS renewal management.*
