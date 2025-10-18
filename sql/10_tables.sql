-- Shared table design (dev & prod). Placeholders ${CATALOG}, ${SCHEMA}
CREATE TABLE IF NOT EXISTS ${CATALOG}.${SCHEMA}.example_bronze (
  id STRING,
  payload STRING,
  ingest_ts TIMESTAMP
) USING DELTA;

CREATE TABLE IF NOT EXISTS ${CATALOG}.${SCHEMA}.example_silver (
  id STRING,
  metric INT,
  event_ts TIMESTAMP,
  email STRING,
  tenant_id STRING
) USING DELTA;
