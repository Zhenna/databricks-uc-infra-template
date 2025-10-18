import os, pathlib, yaml
ROOT = pathlib.Path(__file__).resolve().parents[1]
CONF_PATH = ROOT / "config" / "constants.yaml"
def _load_yaml():
    if CONF_PATH.exists():
        with open(CONF_PATH, "r") as f:
            return yaml.safe_load(f) or {}
    return {}
_DEFAULTS = _load_yaml()
def get(name: str, default=None):
    # env var (uppercase, dots -> underscores) wins
    env_key = name.upper().replace(".","_")
    if env_key in os.environ:
        return os.environ[env_key]
    # nested lookup via dots
    cur = _DEFAULTS
    for part in name.split("."):
        if isinstance(cur, dict) and part in cur:
            cur = cur[part]
        else:
            return default
    return cur
CATALOG = get("catalog_name","analytics")
DEV_SCHEMA = get("dev_schema","dev")
PROD_SCHEMA = get("prod_schema","prod")
GOV_CATALOG = get("governance_catalog","governance")
GOV_SCHEMA = get("governance_schema","security")
GROUPS = {
    "admins":    get("groups.admins","data_admins"),
    "engineers": get("groups.engineers","data_engineers"),
    "analysts":  get("groups.analysts","data_analysts"),
    "readers":   get("groups.readers","data_readers"),
}
