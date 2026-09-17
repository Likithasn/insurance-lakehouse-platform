select
    c.claim_id,
    c.policy_id,
    cast(date_format(c.claim_date, 'yyyyMMdd') as int) as claim_date_key,
    c.claim_type,
    c.claim_amount,
    coalesce(p.payment_status, 'Payment Quarantined') as payment_status,
    p.amount as payment_amount,
    datediff(p.payment_date, c.claim_date) as settlement_days
from {{ ref('silver_claims') }} c
left join {{ ref('silver_payments') }} p
    on c.claim_id = p.claim_id
