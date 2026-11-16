from datetime import datetime
from pathlib import Path
import duckdb
from airflow.sdk import DAG, task

BASE_DIR = Path(__file__).resolve().parent.parent
CONSULTAS_DIR = BASE_DIR / "consultas"
DATOS_DIR = BASE_DIR / "datos"
DB_PATH = BASE_DIR / "pipeline.duckdb"


def read_sql(filename: str):
    return (CONSULTAS_DIR / filename).read_text(encoding="utf-8")


def count(con, table):
    return con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]


@DAG(
    dag_id="pipeline_envios_etl",
    start_date=datetime(2026, 1, 1),
    schedule="0 2 * * *",
    catchup=False,
)
def dag_pipeline():
    @task
    def extract():
        con = duckdb.connect(str(DB_PATH))
        con.execute(read_sql(filename="extract.sql"), [str(DATOS_DIR / "ventas.csv")])
        print("Valores extraidos: ", count(con, "envios_raw"))
        con.close()

    @task
    def validate():
        con = duckdb.connect(str(DB_PATH))
        con.execute(read_sql(filename="validar.sql"))
        print("Valores validos: ", count(con, "envios_validos"))
        con.close()

    @task
    def transform():
        con = duckdb.connect(str(DB_PATH))
        con.execute(read_sql(filename="limpiar.sql"))
        con.execute(read_sql(filename="unir.sql"))
        print("Valores en tabla final: ", count(con, "tabla_final"))
        con.close()

    @task
    def export():
        con = duckdb.connect(str(DB_PATH))
        df = con.execute("SELECT * FROM tabla_final").df()
        df.to_parquet(str(BASE_DIR / "output" / "envios_final.parquet"))
        con.close()

    extract() >> validate() >> transform() >> export()


dag_instance = dag_pipeline()
