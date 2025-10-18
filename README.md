# Databricks UC Template with Governance Catalog

This repo bootstraps:
- **Governance** catalog/schema for reusable UC policies (`governance.security`)
- **Work** catalog with **dev** and **prod** schemas
- **Column masking** & **row filters** applied via SQL bindings after table creation
- Deployable via **Terraform** + **Databricks Bundles**

## Order of operations
1) `cd infra/terraform && terraform init && terraform apply -var="workspace_host=..." -var="workspace_token=..."`  
   (creates catalogs/schemas and grants)
2) `databricks bundle deploy -t dev` (or `-t prod`)
3) `databricks bundle run create_tables_and_bindings -t dev`

## Files
- `sql/10_tables.sql` – table design (with demo `email`, `tenant_id`)
- `sql/20_policies.sql` – defines masking/row filter in `${GOV_CATALOG}.${GOV_SCHEMA}`
- `sql/30_bindings.sql` – applies policies to your tables per target schema
- `src/sql_runner.py` – executes 20→10→30 for dev & prod using placeholders
- `config/constants.yaml` – shared non-secret defaults; env vars override
