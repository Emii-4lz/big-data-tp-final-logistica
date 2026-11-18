-- P1: Promedio de dias de entrega por transportista
SELECT
    transportista,
    ROUND(AVG(dias_entrega), 2) AS promedio_dias_entrega,
    COUNT(*)                    AS cantidad_envios
FROM tabla_final
GROUP BY transportista
ORDER BY promedio_dias_entrega;

-- P2: Costo total de envios por transportista (ARS)
SELECT
    transportista,
    ROUND(SUM(costo_envio), 2) AS costo_total_ars
FROM tabla_final
GROUP BY transportista
ORDER BY costo_total_ars DESC;

-- P3: Top 5 rutas con mas envios
SELECT
    origen,
    destino,
    origen || ' -> ' || destino AS ruta,
    COUNT(*)                    AS cantidad_envios
FROM tabla_final
GROUP BY origen, destino
ORDER BY cantidad_envios DESC, origen, destino
LIMIT 5;

-- P4: Kilos enviados en total por destino
SELECT
    destino,
    ROUND(SUM(peso_kg), 2) AS kg_totales
FROM tabla_final
GROUP BY destino
ORDER BY kg_totales DESC;

-- P5: Cantidad de envios entregados en mas de 7 dias
SELECT
    COUNT(*) AS envios_mas_de_7_dias
FROM tabla_final
WHERE dias_entrega > 7;
