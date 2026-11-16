CREATE OR REPLACE TABLE tabla_final AS SELECT 
id_envio,
CAST(fecha_despacho AS DATE) AS fecha_despacho,
CAST(fecha_entrega AS DATE) AS fecha_entrega,
TRIM(origen) AS origen,
TRIM(destino) AS destino,
TRIM(transportista) AS transportista,
CAST(peso_kg AS DOUBLE) AS peso_kg,
CAST(costo_envio AS DOUBLE) AS costo_envio,
CAST(dias_entrega AS INTEGER) AS dias_entrega,
'valido' AS registro
FROM validos 

UNION SELECT id_envio,
CAST(fecha_despacho AS DATE) AS fecha_despacho,
CAST(fecha_entrega AS DATE) AS fecha_entrega,
TRIM(origen) AS origen,
TRIM(destino) AS destino,
TRIM(transportista) AS transportista,
CAST(peso_kg AS DOUBLE) AS peso_kg,
CAST(costo_envio AS DOUBLE) AS costo_envio,
CAST(dias_entrega AS INTEGER) AS dias_entrega,
'recuperado' AS registro
FROM rechazados_limpios;