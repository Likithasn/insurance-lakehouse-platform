# Notebooks

Export your Databricks notebooks here as `.py` or `.ipynb` source files
(not just the paths — actual downloadable code), specifically:

- `01_enrich_insurance_data` — the enrichment script with the
  deliberate data-quality-anomaly injection
- `02_bronze_layer` — raw ingestion into Delta tables

To export from Databricks: open the notebook → **File → Export →
Source File** (for `.py`) or **IPYNB** — then drag the downloaded
file into this folder before committing.

Note: `03_silver_layer` and `04_gold_layer` are intentionally NOT
included here — that logic now lives in `dbt_project/` instead,
since it was rebuilt in dbt. Keeping the old PySpark versions out of
this repo avoids confusion about which version is the "real" pipeline.
