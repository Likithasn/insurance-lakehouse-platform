# Data Quality Validation

## The rule

The Silver layer quarantines payment records where `payment_status`
and `amount` are inconsistent — for example, a record marked `'Paid'`
with a zero amount, or marked `'Rejected'`/`'Pending'` with a nonzero
amount. Flagged records are held in a separate `quarantine_payments`
table for review, rather than being silently dropped or auto-corrected.

## The problem: a rule that passes for the wrong reason

On first run, this rule flagged **zero** records. The natural
conclusion — "the data is clean" — would have been wrong. The actual
reason: the synthetic data generator (`enrich_insurance_data.py`)
always produced internally consistent payment records by
construction (`amount = claim_amount if status == "Paid" else 0`),
so there was never a chance for an inconsistent record to exist. A
rule that can never fail is not a validated rule — it's an untested
one.

## The fix: deliberately inject anomalies

A small number of payment records (~2%) were intentionally
corrupted after generation — flipping a `'Paid'` record's amount to
zero, or giving a `'Rejected'`/`'Pending'` record a nonzero amount —
specifically to test whether the quarantine rule actually catches
what it's designed to catch.

## The result

74 records (1.94% of payments) were correctly identified and
quarantined. This also surfaced a downstream effect: claims whose
payment was quarantined lost their payment match entirely in the
`fact_claims` Gold model (built via a `LEFT JOIN` against
`silver_payments`, which excludes quarantined rows). This first
appeared in Power BI as an unexplained `(Blank)` category in the
`payment_status` field — traced back with a SQL query joining
`silver_claims` to `silver_payments` to confirm the exact count
matched the quarantine table (74), confirming the mechanism was
working as designed, not a join bug. The Gold model was then updated
to explicitly label this case as `'Payment Quarantined'` rather than
leaving it blank.

## Why this matters

A data quality rule is only meaningful if it's been shown to catch
something. Testing a rule against data that was generated to already
satisfy it produces a false sense of confidence. This is a general
principle worth applying to any synthetic test dataset, not just this
project.
