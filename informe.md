# Informe - Pipeline ETL RapiCargo Logística

**Fuente:** `datos/envios.csv` (2575 filas, 9 columnas, clave `id_envio`). **Resultado:** `tabla_final` con **2500 envíos** (1382 válidos + 1118 recuperados). Se eliminaron 75 filas duplicadas: 1382 + 1193 que fueron rechazados = 2575 y 1193 − 75 duplicados = 1118 limpios.

## 1. Problemas encontrados

- **75 filas duplicadas** (mismo `id_envio`, filas idénticas).
- **Fechas en otro formato:** ~205 `fecha_despacho` y ~206 `fecha_entrega` en `dd/mm/yyyy` en vez de `YYYY-MM-DD`.
- **Transportista sucio:** MAYÚSCULAS y/o espacios al inicio (`" OCA"`, `ANDREANI`): 207 registros.
- **Peso negativo:** 103 registros.
- **Costo con formato local** (`24.624,00`): 126 registros, no se puede convertir a número directamente.
- **`dias_entrega` vacío:** 153 registros.
- **Fechas invertidas** (`fecha_entrega` anterior a `fecha_despacho`): 103 registros.

## 2. Rechazos por regla

Cada fila queda con el motivo de la **primera** regla que falla (12 reglas en `consultas/validar.sql`).

| Regla                                                          | Rechazos | Cómo se corrigió                 |
| -------------------------------------------------------------- | -------- | -------------------------------- |
| fecha_despacho_invalida                                        | 195      | `strptime` dd/mm/yyyy → DATE     |
| fecha_entrega_invalida                                         | 194      | `strptime` dd/mm/yyyy → DATE     |
| transportista_no_permitido                                     | 193      | `LOWER(TRIM())`                  |
| dias_entrega_nulo                                              | 147      | `fecha_entrega - fecha_despacho` |
| id_duplicado                                                   | 146      | `SELECT DISTINCT` deja una copia |
| costo_invalido                                                 | 124      | `REPLACE` de `.` y `,`           |
| peso_no_positivo                                               | 97       | `ABS()`                          |
| entrega_antes_de_despacho                                      | 97       | se intercambian las fechas       |
| id_nulo, origen_vacio, destino_vacio, dias_entrega_no_positivo | 0        | -                                |
| **Total rechazados**                                           | **1193** |                                  |

Tablas en `pipeline.duckdb`: `raw_envios`, `envios_chequeo`, `validos`, `rechazados`, `rechazados_paso1`, `rechazados_limpios`, `tabla_final`, `respuesta_p1` a `respuesta_p5`.

## 3. Respuestas a las preguntas de negocio (sobre `tabla_final`)

**P1. Promedio de días de entrega:** andreani 4,92 · mercado_envios 5,05 · correo_argentino 5,05 · oca 5,13.

**P2. Costo total por transportista (ARS):** andreani 20.574.874,12 · mercado_envios 19.766.613,33 · correo_argentino 19.353.175,78 · oca 18.242.444,84.

**P3. Top 5 rutas:** Mendoza→Buenos Aires (80) · Salta→Mendoza (77) · Salta→Bahia Blanca (73) · Mendoza→Bahia Blanca (71) · Cordoba→Buenos Aires (70).

**P4. Kg totales por destino:** Bahia Blanca 7.782,23 · Rosario 7.604,10 · Mendoza 7.429,99 · Buenos Aires 7.384,30 · Tucuman 7.311,03 · Cordoba 6.888,85 · Salta 6.711,48.

**P5. Envíos entregados en más de 7 días:** **562**.

## 4. Automatización

DAG `pipeline_envios_etl` (`dags/dag_pipeline.py`) con `schedule="0 2 * * *"` (todos los días a las 2:00 AM, zona horaria de Argentina). Tareas encadenadas: `extract >> validate >> clean >> merge >> questions`. Usa `CREATE OR REPLACE TABLE`, por lo que puede correr varias veces sin duplicar datos.
