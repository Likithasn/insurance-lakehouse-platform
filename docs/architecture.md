# Architecture Design Decisions

## Why a Lakehouse, not a Data Warehouse or Data Lake alone

- A **Data Warehouse** alone would be fast and governed for BI, but
  rigid — raw enrichment logic (synthetic data generation, custom
  premium formulas) doesn't fit naturally into schema-on-write SQL.
- A **Data Lake** alone would store raw files cheaply and flexibly,
  but with no ACID transactions or schema enforcement, it easily
  becomes a "data swamp" with no reliable structure for BI to query.
- A **Lakehouse** (Delta Lake on Databricks) combines the Lake's cheap,
  flexible storage with the Warehouse's governance and ACID
  transactions — the right fit for a project needing both raw-file
  ingestion and reliable, testable, BI-ready tables.

## Why PySpark for ingestion, dbt for transformation

dbt has no compute engine of its own — it compiles SQL and sends it
to the warehouse to run. It cannot read a raw CSV file or run
arbitrary Python logic (Faker-based synthetic data generation,
custom weighted formulas). PySpark can do both. So:

- **PySpark** — Bronze layer only: reading raw files, running
  enrichment logic, writing to Delta tables.
- **dbt** — Silver and Gold layers: pure SQL transformation, testing
  (`unique`, `not_null`, `relationships`), and automatic lineage via
  `ref()`. This is not a stylistic choice — it reflects what each
  tool is structurally capable of.

## Why a star schema, not Snowflake schema or Data Vault

- **Snowflake schema** (further-normalized dimensions) would reduce
  redundancy slightly but add extra joins, slowing down the exact
  BI queries this platform exists to serve.
- **Data Vault** (Hubs/Links/Satellites) is built for auditability
  across many rapidly-changing enterprise source systems — genuinely
  valuable at true enterprise scale, but overkill for this project's
  scope, where Bronze/Delta versioning already provides an audit
  trail.
- **Star schema** — two fact tables (`fact_policy`, `fact_claims`)
  sharing conformed dimensions (`dim_customer`, `dim_agent`,
  `dim_policy`, `dim_date`) — is the right fit: fast for BI tools,
  simple to reason about, and appropriately scoped for this project's
  data volume and single-team context.

## Why Power BI connects directly to the SQL Warehouse (not CSV import)

Any refresh in the Gold layer is immediately reflected in the report
without a manual re-export step — this mirrors how enterprise BI is
actually deployed, where Power BI is a pure reporting/visualization
layer and never performs transformation.

## Known limitation: Apache NiFi was not implemented

The original design included Apache NiFi for automated file ingestion
(scheduling, retry, error routing). Given project time constraints,
this was deprioritized in favor of deepening the transformation layer
(the PySpark → dbt conversion) and building out a complete 4-page
Power BI reporting layer. Ingestion is currently a manual file upload
to a Unity Catalog volume. A natural next step would be adding NiFi
(or a Databricks-native scheduled job/Auto Loader) in front of the
existing Bronze notebook, without needing to change anything
downstream.
