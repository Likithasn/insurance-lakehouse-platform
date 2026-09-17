# Data Dictionary — Gold Layer

## dim_customer
| Column | Description |
|---|---|
| customer_id | Unique customer identifier (synthetic) |
| customer_name | Customer name (synthetic, via Faker) |
| gender | Customer gender (synthetic) |
| customer_age | Customer age |

## dim_agent
| Column | Description |
|---|---|
| agent_id | Unique agent identifier (synthetic) |
| agent_name | Agent name (synthetic, via Faker) |
| region | Sales region (North/South/East/West/Central) |
| hire_date | Agent hire date (synthetic) |
| commission_rate | Commission rate applied to premium sold |

## dim_policy
| Column | Description |
|---|---|
| policy_id | Unique policy identifier (source dataset) |
| segment | Vehicle segment code |
| model | Vehicle model code |
| fuel_type | Fuel type (Diesel/Petrol/etc.) |
| engine_type | Engine type code |
| airbags | Number of airbags |
| ncap_rating | Vehicle safety rating |
| transmission_type | Manual/Automatic |
| vehicle_age | Age of insured vehicle in years |
| region_code | Source-dataset region code (distinct from agent region) |

## dim_date
| Column | Description |
|---|---|
| date | Calendar date |
| date_key | Integer surrogate key (yyyyMMdd) |
| year / month / month_name / quarter | Calendar attributes |

## fact_policy (grain: one row per policy)
| Column | Description |
|---|---|
| policy_id | Foreign key → dim_policy |
| customer_id | Foreign key → dim_customer |
| agent_id | Foreign key → dim_agent |
| start_date_key / end_date_key | Foreign keys → dim_date (role-playing dimension) |
| premium | Premium charged, derived from a risk-based formula (see architecture.md) |
| claim_status | 1 if the policy resulted in a claim, else 0 |

## fact_claims (grain: one row per claim)
| Column | Description |
|---|---|
| claim_id | Unique claim identifier |
| policy_id | Foreign key → dim_policy |
| claim_date_key | Foreign key → dim_date |
| claim_type | Collision / Theft / Fire / Third-Party / Natural Calamity |
| claim_amount | Amount claimed |
| payment_status | Paid / Pending / Rejected / Payment Quarantined |
| payment_amount | Amount actually paid (0 if not Paid) |
| settlement_days | Days between claim filed and payment made (null if unpaid) |

## quarantine_payments (audit table, not part of the star schema)
| Column | Description |
|---|---|
| payment_id | Unique payment identifier |
| claim_id | Related claim |
| amount | Payment amount as recorded |
| payment_status | Status as recorded |
| payment_date | Payment date (if any) |

Flagged when `payment_status`/`amount` are inconsistent — see
`docs/data-quality.md` for the full rule and validation story.
