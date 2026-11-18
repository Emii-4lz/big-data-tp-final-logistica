CREATE OR REPLACE TABLE tabla_final AS
SELECT
    id_envio,
    COALESCE(
    try_strptime(fecha_despacho, '%d/%m/%Y')::DATE,
    try_strptime(fecha_despacho, '%Y-%m-%d')::DATE
) AS fecha_despacho,
    COALESCE(
    try_strptime(fecha_entrega, '%d/%m/%Y')::DATE,
    try_strptime(fecha_entrega, '%Y-%m-%d')::DATE
) AS fecha_entrega,
    TRIM(origen) AS origen,
    TRIM(destino) AS destino,
    TRIM(transportista) AS transportista,
    CAST(peso_kg AS DOUBLE) AS peso_kg,
    CAST(REPLACE(REPLACE(costo_envio, '.', ''), ',', '.') AS DOUBLE) AS costo_envio,
    CAST(dias_entrega AS INTEGER) AS dias_entrega,
    'valido' AS registro
FROM validos

UNION

SELECT
    id_envio,
    COALESCE(
    try_strptime(fecha_despacho, '%d/%m/%Y')::DATE,
    try_strptime(fecha_despacho, '%Y-%m-%d')::DATE
) AS fecha_despacho,
    COALESCE(
    try_strptime(fecha_entrega, '%d/%m/%Y')::DATE,
    try_strptime(fecha_entrega, '%Y-%m-%d')::DATE
) AS fecha_entrega,
    TRIM(origen) AS origen,
    TRIM(destino) AS destino,
    TRIM(transportista) AS transportista,
    CAST(peso_kg AS DOUBLE) AS peso_kg,
    CAST(REPLACE(REPLACE(costo_envio, '.', ''), ',', '.') AS DOUBLE) AS costo_envio,
    CAST(dias_entrega AS INTEGER) AS dias_entrega,
    'recuperado' AS registro
FROM rechazados_limpios;