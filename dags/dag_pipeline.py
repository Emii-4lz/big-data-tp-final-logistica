import pendulum
from pathlib import Path
import duckdb
from airflow.sdk import dag, task

BASE_DIR = Path(__file__).resolve().parent.parent
CONSULTAS_DIR = BASE_DIR / "consultas"
DATOS_DIR = BASE_DIR / "datos"
DB_PATH = BASE_DIR / "pipeline.duckdb"


def read_sql(filename: str):
    return (CONSULTAS_DIR / filename).read_text(encoding="utf-8")


def count(con, table):
    return con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]


@dag(
    dag_id="pipeline_envios_etl",
    start_date=pendulum.datetime(2026, 1, 1, tz="America/Argentina/Buenos_Aires"),
    schedule="0 2 * * *",
    catchup=False,
)
def dag_pipeline():
    @task
    def extract():
        con = duckdb.connect(str(DB_PATH))
        con.execute(read_sql(filename="extract.sql"), [str(DATOS_DIR / "envios.csv")])
        print("Valores extraidos: ", count(con, "raw_envios"))
        con.close()

    @task
    def validate():
        con = duckdb.connect(str(DB_PATH))
        con.execute(read_sql(filename="validar.sql"))
        print("Valores validos: ", count(con, "validos"))
        print("Valores rechazados: ", count(con, "rechazados"))
        con.close()

    @task
    def limpiar():
        con = duckdb.connect(str(DB_PATH))
        con.execute(read_sql(filename="limpiar.sql"))
        print("Valores rechazados limpios: ", count(con, "rechazados_limpios"))
        con.close()

    @task
    def unir():
        con = duckdb.connect(str(DB_PATH))
        con.execute(read_sql(filename="unir.sql"))
        print("Valores en tabla final: ", count(con, "tabla_final"))
        con.close()


    extract() >> validate() >> limpiar() >> unir()


dag_instance = dag_pipeline()
