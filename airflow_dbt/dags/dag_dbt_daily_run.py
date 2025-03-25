from airflow.decorators import dag, task
from datetime import datetime
from include.dbt.cosmos_config import DBT_PROJECT_CONFIG, DBT_CONFIG
from cosmos.airflow.task_group import DbtTaskGroup
from cosmos.constants import LoadMode
from cosmos.config import ProjectConfig, RenderConfig
from airflow.models.baseoperator import chain
from airflow.operators.dummy import DummyOperator
from airflow.providers.google.cloud.transfers.s3_to_gcs import S3ToGCSOperator
from airflow.exceptions import AirflowException


@dag(
    start_date=datetime(2024, 7, 7),
    schedule=None,
    catchup=False,
)
def dbt_daily_run():

    # Operador para garantir o início da execução
    start = DummyOperator(task_id='start')




    # Definir os task groups para os modelos
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

    datamart = DbtTaskGroup(
        group_id='datamart',
        project_config=DBT_PROJECT_CONFIG,
        profile_config=DBT_CONFIG,
        render_config=RenderConfig(
            load_method=LoadMode.DBT_LS,
            select=['path:models/datamart']
        )
    )


    # Estabelecer dependências para execução sequencial respeitando a lineage
    start >> bronze >> silver >> gold >> datamart 

    # Adicionando as dependências para a execução dos testes após os modelos


    # Acessando as tarefas dentro de cada task group e aplicando o on_failure_callback
    for task_group in [bronze, silver, gold]:
        for task in task_group:
            task.on_failure_callback = lambda context: None  # Não interromper a DAG

    # Garantir que a execução dos testes aconteça depois dos modelos
    chain(bronze, silver, gold, datamart)


dbt_daily_run()