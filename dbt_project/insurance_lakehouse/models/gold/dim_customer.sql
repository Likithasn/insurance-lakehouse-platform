with source as (
    select customer_id, customer_name, gender, customer_age
    from {{ ref('silver_policies') }}
),

deduped as (
    select *,
        row_number() over (partition by customer_id order by customer_id) as rn
    from source
)

select * except (rn)
from deduped
where rn = 1
