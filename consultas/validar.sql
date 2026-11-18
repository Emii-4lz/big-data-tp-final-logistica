CREATE OR REPLACE TABLE envios_validacion AS
SELECT *,
    CASE
        WHEN id_envio IS NULL OR TRIM(id_envio) = '' THEN 'id_nulo'
        WHEN id_envio IN (SELECT id_envio FROM raw_envios GROUP BY id_envio HAVING COUNT(*) > 1)
            THEN 'id_duplicado'
        WHEN TRY_CAST(fecha_despacho AS DATE) IS NULL THEN 'fecha_despacho_invalida'
        WHEN TRY_CAST(fecha_entrega AS DATE) IS NULL THEN 'fecha_entrega_invalida'
        WHEN TRY_CAST(fecha_entrega AS DATE) < TRY_CAST(fecha_despacho AS DATE)
            THEN 'entrega_antes_de_despacho'
        WHEN origen IS NULL OR TRIM(origen) = '' THEN 'origen_vacio'
        WHEN destino IS NULL OR TRIM(destino) = '' THEN 'destino_vacio'
        WHEN transportista IS NULL
            OR transportista NOT IN ('andreani', 'oca', 'correo_argentino', 'mercado_envios')
            THEN 'transportista_no_permitido'
        WHEN TRY_CAST(peso_kg AS DOUBLE) IS NULL OR TRY_CAST(peso_kg AS DOUBLE) <= 0
            THEN 'peso_no_positivo'
        WHEN TRY_CAST(costo_envio AS DOUBLE) IS NULL OR TRY_CAST(costo_envio AS DOUBLE) <= 0
            THEN 'costo_invalido'
        WHEN dias_entrega IS NULL THEN 'dias_entrega_nulo'
        WHEN dias_entrega <= 0 THEN 'dias_entrega_no_positivo'
        ELSE NULL
    END AS motivo_rechazo
FROM raw_envios;

CREATE OR REPLACE TABLE validos AS
SELECT id_envio, fecha_despacho, fecha_entrega, origen, destino,
       transportista, peso_kg, costo_envio, dias_entrega
FROM envios_validacion
WHERE motivo_rechazo IS NULL;

CREATE OR REPLACE TABLE rechazados AS
SELECT *
FROM envios_validacion
WHERE motivo_rechazo IS NOT NULL;
