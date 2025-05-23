from airflow.decorators import dag, task
from datetime import datetime, timedelta
from cosmos.airflow.task_group import DbtTaskGroup
from cosmos.constants import LoadMode
from cosmos.config import ProjectConfig, RenderConfig
from airflow.operators.dummy import DummyOperator
from airflow.providers.google.cloud.transfers.s3_to_gcs import S3ToGCSOperator
from airflow.utils.task_group import TaskGroup
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


@dag(
    start_date=datetime(2024, 7, 24),
    schedule=None,
    catchup=False,
    tags=['dbt', 'daily_run'],
    default_args={
        'retries': 2,
        'retry_delay': timedelta(minutes=5),
        'execution_timeout': timedelta(hours=2),
    }
)
def dbt_daily_run():


    start = DummyOperator(task_id='start')


    s3_to_gcs_transfer = S3ToGCSOperator(
        task_id='s3_to_gcs_transfer',
        bucket='upstart-bucket',
        aws_conn_id='my_aws_conn',
        gcp_conn_id='db_conn',
        dest_gcs='gs://s3-external-files-bucket-gcs/external_data/',
        apply_gcs_prefix=True,
        replace=True
    )

    bronze = DbtTaskGroup(
        group_id='bronze',
        project_config=DBT_PROJECT_CONFIG,
        profile_config=DBT_CONFIG,
        render_config=RenderConfig(
            load_method=LoadMode.DBT_LS,
            select=['path:models/bronze']
        )
    )

    silver = DbtTaskGroup(
        group_id='silver',
        project_config=DBT_PROJECT_CONFIG,
        profile_config=DBT_CONFIG,
        render_config=RenderConfig(
            load_method=LoadMode.DBT_LS,
            select=['path:models/silver']
        )
    )

    gold = DbtTaskGroup(
        group_id='gold',
        project_config=DBT_PROJECT_CONFIG,
        profile_config=DBT_CONFIG,
        render_config=RenderConfig(
            load_method=LoadMode.DBT_LS,
            select=['path:models/gold']
        )
    )

    end = DummyOperator(task_id='end')


    start >> s3_to_gcs_transfer >> bronze >> silver >> gold >> end

dbt_daily_run()