-- Equivalent of the PySpark silver_policies cell:
--   .dropDuplicates(["policy_id"])
--   .withColumn("policy_start_date", to_date(...))
--   .withColumn("policy_end_date", to_date(...))
--   .withColumn("premium", round(cast(double), 2))
--   .filter(policy_id is not null)

with source as (
    select * from {{ source('bronze', 'bronze_policies') }}
),

deduped as (
    select *,
        row_number() over (partition by policy_id order by policy_id) as rn
    from source
    where policy_id is not null
)

select
    * except (rn, policy_start_date, policy_end_date, premium),
    to_date(policy_start_date) as policy_start_date,
    to_date(policy_end_date) as policy_end_date,
    round(cast(premium as double), 2) as premium
from deduped
where rn = 1
