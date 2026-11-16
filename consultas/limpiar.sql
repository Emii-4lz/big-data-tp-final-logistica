CREATE OR REPLACE TABLE rechazados_limpios AS SELECT 
id_envio,
fecha_despacho,
fecha_entrega,
TRIM(origen) AS origen,
TRIM(destino) AS destino,
TRIM(transportista) AS transportista,
peso_kg,
costo_envio,
dias_entrega,
'limpiado' AS motivo_rechazo
FROM rechazados;