variable "workspace_host" { type = string }
variable "workspace_token" { type = string }
variable "metastore_id" { type = string, default = "" }

# Work (data) catalog & schemas
variable "catalog_name" { type = string, default = "analytics" }
variable "dev_schema"   { type = string, default = "dev" }
variable "prod_schema"  { type = string, default = "prod" }

# Governance catalog & schema
variable "governance_catalog_name" { type = string, default = "governance" }
variable "governance_schema_name"  { type = string, default = "security" }

variable "create_groups" { type = bool, default = true }
variable "grp_admins"    { type = string, default = "data_admins" }
variable "grp_engineers" { type = string, default = "data_engineers" }
variable "grp_analysts"  { type = string, default = "data_analysts" }
variable "grp_readers"   { type = string, default = "data_readers" }
