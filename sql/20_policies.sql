-- Create reusable policies in governance catalog/schema
-- Masking: redact email for non-privileged groups; show partially for analysts
CREATE OR REPLACE MASKING POLICY ${GOV_CATALOG}.${GOV_SCHEMA}.pii_email_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN is_account_group_member('data_admins') OR is_account_group_member('data_engineers') THEN val
    WHEN is_account_group_member('data_analysts') THEN regexp_replace(val, '(?<=.).(?=[^@]*@)', '*')
    ELSE 'REDACTED'
  END;

-- Row filter: restrict rows by tenant
CREATE OR REPLACE ROW FILTER ${GOV_CATALOG}.${GOV_SCHEMA}.tenancy_rf AS (tenant_id STRING) RETURNS BOOLEAN ->
  CASE
    WHEN is_account_group_member('tenant_a_readers') THEN tenant_id = 'A'
    WHEN is_account_group_member('tenant_b_readers') THEN tenant_id = 'B'
    ELSE TRUE -- default allow; tighten in prod if needed
  END;
