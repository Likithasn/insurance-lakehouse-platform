# Insurance Lakehouse — dbt project (Silver + Gold layers)

This dbt project takes over the Silver and Gold layers of the pipeline.
Bronze ingestion (reading the CSVs, Faker enrichment) stays in PySpark —
dbt cannot read raw files, so that step is unchanged and lives in your
existing Databricks notebook.

## Folder structure
```
insurance_lakehouse/
  dbt_project.yml          <- project config
  models/
    sources.yml             <- declares the existing bronze_* tables
    schema.yml              <- descriptions + tests for every model
    silver/
      silver_policies.sql
      silver_agents.sql
      silver_claims.sql
      silver_payments.sql
      quarantine_payments.sql
    gold/
      dim_agent.sql
      dim_customer.sql
      dim_policy.sql
      dim_date.sql
      fact_policy.sql
      fact_claims.sql
profiles.yml                 <- connection config (goes in ~/.dbt/, NOT in the project folder)
```

## WHAT YOU MUST CHANGE before running

### 1. `profiles.yml` — 3 values
This file does NOT live inside the project folder when you actually run
dbt — copy it to `~/.dbt/profiles.yml` on your machine (create the `.dbt`
folder if it doesn't exist).

Change these 3 lines to match your own workspace (same values you used
for the Power BI connection):
```yaml
host: dbc-XXXXXXX.cloud.databricks.com      # your Server hostname
http_path: /sql/1.0/warehouses/XXXXXXXXXXXX  # your HTTP path
```
The `token` line uses an environment variable instead of a hardcoded
secret — see step 2.

### 2. Set your Databricks token as an environment variable
Never paste a token directly into profiles.yml. Instead, before running
dbt, set it in your terminal session:
```
export DBT_DATABRICKS_TOKEN="your_token_here"
```
(On Windows/PowerShell: `$env:DBT_DATABRICKS_TOKEN="your_token_here"`)

Get the token from Databricks: User Settings -> Developer -> Access
Tokens -> Generate new token. If your workspace is Free Edition and
doesn't offer this, use OAuth instead — see the dbt-databricks docs for
the OAuth variant of profiles.yml.

### 3. `catalog` / `schema` values (if yours differ)
Every model and `dbt_project.yml`/`sources.yml` currently assumes:
- catalog: `workspace`
- bronze schema: `default`
- silver/gold will be written to schemas named `silver` and `gold`
  automatically (see the `+schema:` config in dbt_project.yml)

If your bronze tables live under a different catalog/schema, update
`models/sources.yml` accordingly.

## How to run it
```bash
pip install dbt-databricks
cd insurance_lakehouse
dbt debug     # tests your connection — fix this before anything else
dbt run       # builds all Silver + Gold models, in dependency order
dbt test      # runs the not_null / unique / relationships tests
dbt docs generate && dbt docs serve   # browsable lineage + documentation
```

## What each dbt test is actually checking
- `unique` / `not_null` on primary keys (policy_id, claim_id, agent_id,
  customer_id) — catches duplication or missing-key issues that would
  silently break your Power BI relationships
- `relationships` on fact tables — confirms every foreign key
  (agent_id, customer_id, policy_id) in a fact table actually exists in
  its dimension table, i.e. no orphaned rows

## Note on the quarantine logic
`quarantine_payments.sql` and `silver_payments.sql` together reproduce
the PySpark quarantine pattern: payments with inconsistent
status/amount combinations are captured separately instead of being
silently dropped, and excluded from the clean `silver_payments` table
via a left-anti-style join.
