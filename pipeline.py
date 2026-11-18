import duckdb
from pathlib import Path
import pandas as pd

BASE_DIR = Path(__file__).resolve().parent
CONSULTAS_DIR = BASE_DIR / "consultas"
CSV_PATH = BASE_DIR / "datos" / "envios.csv"
DB_PATH = BASE_DIR / "pipeline.duckdb"

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
    return con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]


def extract():
    try:
        print("------ EXTRAYENDO ------")
        con = duckdb.connect(str(DB_PATH))
        con.execute(read_sql("extract.sql"), [str(CSV_PATH)])
        print("Valores extraidos: ", count(con, "raw_envios"))
        con.close()
    except Exception as e:
        raise e


def validate():
    try:
        print("------ VALIDANDO ------")
        con = duckdb.connect(str(DB_PATH))
        con.execute(read_sql("validar.sql"))
        print("Valores validos: ", count(con, "validos"))
        print("Valores rechazados: ", count(con, "rechazados"))
        print("Rechazos por regla:")
        filas = con.execute("""
            SELECT motivo_rechazo, COUNT(*) FROM rechazados
            GROUP BY motivo_rechazo ORDER BY COUNT(*) DESC
        """).fetchall()
        for motivo, cantidad in filas:
            print("   ", motivo, ":", cantidad)
        con.close()
    except Exception as e:
        raise e


def limpiar():
    try:
        print("------ LIMPIANDO ------")
        con = duckdb.connect(str(DB_PATH))
        con.execute(read_sql("limpiar.sql"))
        print("Valores rechazados limpios: ", count(con, "rechazados_limpios"))
        con.close()
    except Exception as e:
        raise e


def unir():
    try:
        print("------ UNIENDO ------")
        con = duckdb.connect(str(DB_PATH))
        con.execute(read_sql("unir.sql"))
        print("Valores en tabla final: ", count(con, "tabla_final"))
        unicos = con.execute("SELECT COUNT(DISTINCT id_envio) FROM tabla_final").fetchone()[0]
        print("Ids unicos en tabla final: ", unicos)
        con.close()
    except Exception as e:
        raise e

def main():
    extract()
    validate()
    limpiar()
    unir()


if __name__ == "__main__":
    main()
