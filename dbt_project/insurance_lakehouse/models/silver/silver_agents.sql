-- Equivalent of: spark.table("bronze_agents").dropDuplicates(["agent_id"])

with source as (
    select * from {{ source('bronze', 'bronze_agents') }}
),

deduped as (
    select *,
        row_number() over (partition by agent_id order by agent_id) as rn
    from source
)

select * except (rn)
from deduped
where rn = 1
