output "work_catalog"        { value = databricks_catalog.work.name }
output "work_dev_schema"     { value = databricks_schema.dev.name }
output "work_prod_schema"    { value = databricks_schema.prod.name }
output "governance_catalog"  { value = databricks_catalog.governance.name }
output "governance_schema"   { value = databricks_schema.gov_security.name }
