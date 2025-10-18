-- Bind policies to columns in target schema
ALTER TABLE ${CATALOG}.${SCHEMA}.example_silver
  ALTER COLUMN email SET MASKING POLICY ${GOV_CATALOG}.${GOV_SCHEMA}.pii_email_mask;

ALTER TABLE ${CATALOG}.${SCHEMA}.example_silver
  SET ROW FILTER ${GOV_CATALOG}.${GOV_SCHEMA}.tenancy_rf ON (tenant_id);
