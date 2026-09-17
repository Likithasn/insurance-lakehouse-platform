with bounds as (
    select
        min(policy_start_date) as min_d,
        max(policy_end_date) as max_d
    from {{ ref('silver_policies') }}
),

spine as (
    select explode(sequence(min_d, max_d, interval 1 day)) as date
    from bounds
)

select
    date,
    cast(date_format(date, 'yyyyMMdd') as int) as date_key,
    year(date) as year,
    month(date) as month,
    date_format(date, 'MMMM') as month_name,
    quarter(date) as quarter
from spine
