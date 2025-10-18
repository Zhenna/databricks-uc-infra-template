terraform {
  required_version = ">= 1.5.0"
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.52.0"
    }
  }
}

provider "databricks" {
  host  = var.workspace_host
  token = var.workspace_token
}

# Optional: attach existing metastore
data "databricks_current_user" "me" {}

resource "databricks_metastore_assignment" "this" {
  count        = var.metastore_id == "" ? 0 : 1
  workspace_id = data.databricks_current_user.workspace_id
  metastore_id = var.metastore_id
  default_catalog_name = var.catalog_name
}

# Groups (optional creation)
resource "databricks_group" "admins"    { count = var.create_groups ? 1 : 0  display_name = var.grp_admins    }
resource "databricks_group" "engineers" { count = var.create_groups ? 1 : 0  display_name = var.grp_engineers }
resource "databricks_group" "analysts"  { count = var.create_groups ? 1 : 0  display_name = var.grp_analysts  }
resource "databricks_group" "readers"   { count = var.create_groups ? 1 : 0  display_name = var.grp_readers   }

# Governance catalog/schema for policies
resource "databricks_catalog" "governance" {
  name    = var.governance_catalog_name
  comment = "Governance catalog for UC security objects (policies, functions)"
  properties = { purpose = "governance" }
}

resource "databricks_schema" "gov_security" {
  catalog_name = databricks_catalog.governance.name
  name         = var.governance_schema_name
  comment      = "Security schema for masking policies and row filters"
}

resource "databricks_grants" "governance_catalog" {
  catalog = databricks_catalog.governance.name
  grant { principal = var.grp_admins    privileges = ["ALL_PRIVILEGES"] }
  grant { principal = var.grp_engineers privileges = ["USE_CATALOG"] }
  grant { principal = var.grp_analysts  privileges = ["USE_CATALOG"] }
  grant { principal = var.grp_readers   privileges = ["USE_CATALOG"] }
}

resource "databricks_grants" "gov_schema" {
  schema = "${databricks_catalog.governance.name}.${databricks_schema.gov_security.name}"
  grant { principal = var.grp_admins    privileges = ["ALL_PRIVILEGES"] }
  grant { principal = var.grp_engineers privileges = ["USAGE","CREATE","MODIFY"] }
  grant { principal = var.grp_analysts  privileges = ["USAGE"] }
  grant { principal = var.grp_readers   privileges = ["USAGE"] }
}

# Work catalog (data) + dev/prod schemas
resource "databricks_catalog" "work" {
  name    = var.catalog_name
  comment = "Analytics work catalog"
  properties = { purpose = "analytics" }
}

resource "databricks_schema" "dev" {
  catalog_name = databricks_catalog.work.name
  name         = var.dev_schema
  comment      = "Development schema"
  properties   = { tier = "dev" }
}

resource "databricks_schema" "prod" {
  catalog_name = databricks_catalog.work.name
  name         = var.prod_schema
  comment      = "Production schema"
  properties   = { tier = "prod" }
}

resource "databricks_grants" "work_catalog" {
  catalog = databricks_catalog.work.name
  grant { principal = var.grp_admins    privileges = ["ALL_PRIVILEGES"] }
  grant { principal = var.grp_engineers privileges = ["USE_CATALOG"] }
  grant { principal = var.grp_analysts  privileges = ["USE_CATALOG"] }
  grant { principal = var.grp_readers   privileges = ["USE_CATALOG"] }
}

resource "databricks_grants" "dev_schema" {
  schema = "${databricks_catalog.work.name}.${databricks_schema.dev.name}"
  grant { principal = var.grp_admins    privileges = ["ALL_PRIVILEGES"] }
  grant { principal = var.grp_engineers privileges = ["USAGE","CREATE","MODIFY"] }
  grant { principal = var.grp_analysts  privileges = ["USAGE"] }
  grant { principal = var.grp_readers   privileges = ["USAGE"] }
  grant { principal = var.grp_engineers privileges = ["SELECT"] on_future = true object_type = "TABLE" }
  grant { principal = var.grp_analysts  privileges = ["SELECT"] on_future = true object_type = "TABLE" }
  grant { principal = var.grp_readers   privileges = ["SELECT"] on_future = true object_type = "TABLE" }
}

resource "databricks_grants" "prod_schema" {
  schema = "${databricks_catalog.work.name}.${databricks_schema.prod.name}"
  grant { principal = var.grp_admins    privileges = ["ALL_PRIVILEGES"] }
  grant { principal = var.grp_engineers privileges = ["USAGE"] }
  grant { principal = var.grp_analysts  privileges = ["USAGE"] }
  grant { principal = var.grp_readers   privileges = ["USAGE"] }
  grant { principal = var.grp_engineers privileges = ["SELECT"] on_future = true object_type = "TABLE" }
  grant { principal = var.grp_analysts  privileges = ["SELECT"] on_future = true object_type = "TABLE" }
  grant { principal = var.grp_readers   privileges = ["SELECT"] on_future = true object_type = "TABLE" }
}
