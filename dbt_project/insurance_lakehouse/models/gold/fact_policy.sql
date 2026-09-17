select
    policy_id,
    customer_id,
    agent_id,
    cast(date_format(policy_start_date, 'yyyyMMdd') as int) as start_date_key,
    cast(date_format(policy_end_date, 'yyyyMMdd') as int) as end_date_key,
    premium,
    claim_status
from {{ ref('silver_policies') }}
