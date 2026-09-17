select
    agent_id,
    agent_name,
    region,
    hire_date,
    commission_rate
from {{ ref('silver_agents') }}
