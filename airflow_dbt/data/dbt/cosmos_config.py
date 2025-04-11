from cosmos.config import ProfileConfig, ProjectConfig
from pathlib import Path

DBT_CONFIG = ProfileConfig(
    profile_name='dbt_upstart',
    target_name='dev',
    profiles_yml_filepath=Path('/usr/local/airflow/data/dbt/profiles.yml')
)

DBT_PROJECT_CONFIG = ProjectConfig(
    dbt_project_path='/usr/local/airflow/data/dbt/',
)