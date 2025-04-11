from cosmos.config import ProfileConfig, ProjectConfig
from pathlib import Path
import os

if os.environ.get("ENV_TYPE") == "LOCAL":
    base_path = Path("/usr/local/airflow/data/dbt/")
else:
    base_path = Path("/home/airflow/gcs/data/dbt/")

DBT_CONFIG = ProfileConfig(
    profile_name='dbt_upstart',
    target_name='dev',
    profiles_yml_filepath=base_path / "profiles.yml"
)

DBT_PROJECT_CONFIG = ProjectConfig(
    dbt_project_path=str(base_path),
)