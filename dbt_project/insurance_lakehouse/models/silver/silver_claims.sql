-- Equivalent of the PySpark silver_claims cell:
--   .dropDuplicates(["claim_id"])
--   .withColumn("claim_date", to_date(...))
--   .filter(claim_amount > 0)   -- data quality rule: no zero/negative claims

with source as (
    select * from {{ source('bronze', 'bronze_claims') }}
),

deduped as (
    select *,
        row_number() over (partition by claim_id order by claim_id) as rn
    from source
)

select
    * except (rn, claim_date),
    to_date(claim_date) as claim_date
from deduped
where rn = 1
  and claim_amount > 0
