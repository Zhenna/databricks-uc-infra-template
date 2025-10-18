import os
from pyspark.sql import SparkSession
from src.constants import CATALOG as DEF_CATALOG, DEV_SCHEMA as DEF_DEV, PROD_SCHEMA as DEF_PROD, GOV_CATALOG as DEF_GCAT, GOV_SCHEMA as DEF_GSCH

def render(sql_text: str, subs: dict) -> str:
    out = sql_text
    for k,v in subs.items():
        out = out.replace("${"+k+"}", v)
    return out

def run_file(spark, path, subs):
    if not os.path.exists(path):
        return
    with open(path,"r") as f:
        sql = render(f.read(), subs)
    statements = [s.strip() for s in sql.split(";") if s.strip()]
    for stmt in statements:
        spark.sql(stmt)

def main():
    spark = SparkSession.builder.getOrCreate()
    repo_root = os.path.dirname(os.path.dirname(__file__))

    # Allow env overrides
    catalog = os.environ.get("CATALOG", DEF_CATALOG)
    dev_schema = os.environ.get("DEV_SCHEMA", DEF_DEV)
    prod_schema = os.environ.get("PROD_SCHEMA", DEF_PROD)
    gov_catalog = os.environ.get("GOVERNANCE_CATALOG", DEF_GCAT)
    gov_schema  = os.environ.get("GOVERNANCE_SCHEMA", DEF_GSCH)

    subs_common = {
        "CATALOG": catalog,
        "GOV_CATALOG": gov_catalog,
        "GOV_SCHEMA": gov_schema,
    }

    # 1) Create/replace governance policies (idempotent)
    run_file(spark, os.path.join(repo_root,"sql","20_policies.sql"), subs_common)

    # 2) For each environment schema: create tables, then apply bindings
    for schema in [dev_schema, prod_schema]:
        subs = dict(subs_common)
        subs["SCHEMA"] = schema
        run_file(spark, os.path.join(repo_root,"sql","10_tables.sql"), subs)
        run_file(spark, os.path.join(repo_root,"sql","30_bindings.sql"), subs)

if __name__ == "__main__":
    main()
