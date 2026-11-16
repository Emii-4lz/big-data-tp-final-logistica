import duckdb
import pandas as pd
from pathlib import Path
from airflow.sdk import task

BASE_DIR = Path(__file__).resolve().parent
CONSULTAS_DIR = BASE_DIR / "consultas"
DATOS_DIR = BASE_DIR / "datos" / "envios.csv"

ver_base_de_datos = pd.read_csv("datos/envios.csv")
# Las revisiones que llevé acabo (Emi):
# print(ver_base_de_datos.isna())
# print(ver_base_de_datos.isna().sum()) - 153 nulos en dias_entrega
# print(ver_base_de_datos.min()) - El minimo de peso_kg es -39.43
# print(ver_base_de_datos.nunique())


def read_sql(filename: str):
    try:
        path = CONSULTAS_DIR / filename
        return path.read_text(encoding="utf-8")
    except Exception as e:
        print("Ocurrió un error al leer el sql ", e)
        raise e


def count(con, table):
    try:
        return con.execute(f"""
        SELECT COUNT(*) FROM {table}
        """)
    except Exception as e:
        raise e


@task
def extract():
    try:
        print("------ EXTRAYENDO ------")
        con = duckdb.connect("pipeline.duckdb")
        con.execute(read_sql(filename="extract.sql"), [str(DATOS_DIR / "envios.csv")])
        print("Valores extraidos: ", count(con, "envios_raw"))
    except Exception as e:
        raise e


@task
def validate():
    try:
        print("------ VALIDANDO ------")
        con = duckdb.connect("pipeline.duckdb")
        con.execute(read_sql(filename="validar.sql"))

        print("Valores rechazados: ", count(con, "rechazados"))
        print("Valores validos: ", count(con, "validos"))
    except Exception as e:
        raise e


@task
def transform():
    try:
        print("------ TRANSFORMANDO Y LIMPIANDO ------")
        con = duckdb.connect("pipeline.duckdb")
        con.execute(read_sql(filename="limpiar.sql"))
        print("Valores rechazados limpios: ", count(con, "rechazados_limpios"))

        con.execute(read_sql(filename="unir.sql"))
        print("Valores en tabla final: ", count(con, "tabla_final"))
    except Exception as e:
        raise e


@task
def export():
    try:
        print("------ EXPORTANDO DATOS . . . ------")
        con = duckdb.connect("pipeline.duckdb")
        df = con.execute("SELECT * FROM tabla_final").df()
        df.to_parquet(str("envios_final.parquet"))
    except Exception as e:
        raise e


def main():
    try:
        extraction = extract()
        validation = validate()
        transforms = transform()
        exports = export()

        extraction >> validation >> transforms >> exports
    except Exception as e:
        print("Error al procesar los datos ", e)


if __name__ == "__main__":
    main()