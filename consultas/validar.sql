CREATE OR REPLACE TABLE rechazados AS
SELECT *, 'rechazado' AS motivo_rechazo FROM envios_raw WHERE fecha_despacho IS NULL OR TRY_CAST(fecha_despacho AS DATE) IS NULL
OR fecha_entrega IS NULL OR TRY_CAST(fecha_entrega AS DATE) IS NULL
OR origen IS NULL OR TRIM(origen) = ''
OR destino IS NULL OR TRIM(destino) = ''
OR transportista IS NULL OR TRIM(transportista) = ''
OR peso_kg IS NULL OR peso_kg <= 0
OR costo_envio IS NULL OR costo_envio <= 0
OR dias_entrega IS NULL OR dias_entrega <= 0;

CREATE OR REPLACE TABLE validos AS
SELECT * FROM envios_raw WHERE fecha_despacho IS NOT NULL AND TRY_CAST(fecha_despacho AS DATE) IS NOT NULL
AND fecha_entrega IS NOT NULL AND TRY_CAST(fecha_entrega AS DATE) IS NOT NULL
AND origen IS NOT NULL AND TRIM(origen) <> ''
AND destino IS NOT NULL AND TRIM(destino) <> ''
AND transportista IS NOT NULL AND TRIM(transportista) <> ''
AND peso_kg IS NOT NULL AND peso_kg > 0
AND costo_envio IS NOT NULL AND costo_envio > 0
AND dias_entrega IS NOT NULL AND dias_entrega > 0;