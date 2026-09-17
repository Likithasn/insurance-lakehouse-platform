-- Equivalent of the PySpark quarantine_payments cell:
-- rows where payment_status/amount are inconsistent (Paid but amount=0, or
-- not Paid but amount>0) are routed here for review instead of being
-- silently dropped or auto-corrected.

select *
from {{ source('bronze', 'bronze_payments') }}
where (payment_status = 'Paid' and amount = 0)
   or (payment_status != 'Paid' and amount > 0)
