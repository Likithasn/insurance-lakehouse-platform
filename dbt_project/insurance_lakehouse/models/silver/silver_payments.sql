-- Equivalent of the PySpark silver_payments cell:
--   .dropDuplicates(["payment_id"])
--   .withColumn("payment_date", to_date(...))
--   .join(quarantine_payments.select("payment_id"), on="payment_id", how="left_anti")

with source as (
    select * from {{ source('bronze', 'bronze_payments') }}
),

deduped as (
    select *,
        row_number() over (partition by payment_id order by payment_id) as rn
    from source
)

select
    d.* except (rn, payment_date),
    to_date(d.payment_date) as payment_date
from deduped d
left join {{ ref('quarantine_payments') }} q
    on d.payment_id = q.payment_id
where d.rn = 1
  and q.payment_id is null   -- left-anti: exclude anything quarantined
