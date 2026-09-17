with source as (
    select
        policy_id, segment, model, fuel_type, engine_type, airbags,
        ncap_rating, transmission_type, vehicle_age, region_code
    from {{ ref('silver_policies') }}
),

deduped as (
    select *,
        row_number() over (partition by policy_id order by policy_id) as rn
    from source
)

select * except (rn)
from deduped
where rn = 1
