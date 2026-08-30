"""
DAG Name: dbt_ecommerce_daily_dag
Purpose: Orchestrates dbt seed -> run -> test inside Airflow Docker.
Schedule: Daily (@daily)
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

# 1. Internal path inside the container (using the already-mounted dags directory from last project)
DBT_PROJECT_DIR = "/opt/airflow/dags/dbt_project"

# 2. Bash command template ensuring PATH includes the local python bin directory 
BASE_DBT_CMD = (
    "export PATH=$PATH:/home/airflow/.local/bin && "
    f"cd {DBT_PROJECT_DIR} && "
    f"dbt {{command}} --project-dir {DBT_PROJECT_DIR} --profiles-dir {DBT_PROJECT_DIR}"
)

# It'll retry once if the command fails, with a 2-minute delay between attempts
default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=2),
}

# ------------ DAG Definition ------------
with DAG(
    dag_id="dbt_ecommerce_daily_dag",
    default_args=default_args,
    description="Daily ETL pipeline running dbt seed, run, and test on Snowflake",
    schedule_interval="@daily",
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=["riham-elsayed", "Snowflake-Session", "Task-2"],
) as dag:

    task_dbt_seed = BashOperator(
        task_id="dbt_seed",
        bash_command=BASE_DBT_CMD.format(command="seed"),
    )

    task_dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=BASE_DBT_CMD.format(command="run"),
    )

    task_dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=BASE_DBT_CMD.format(command="test"),
    )

    task_dbt_seed >> task_dbt_run >> task_dbt_test