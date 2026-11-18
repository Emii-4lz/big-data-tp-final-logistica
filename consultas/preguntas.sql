-- 1. ¿Cual es el promedio de dias de entrega por transportista?
SELECT
    transportista,
    ROUND(AVG(dias_entrega), 2) AS promedio_dias_entrega,
    COUNT(*)                    AS cantidad_envios
FROM tabla_final
GROUP BY transportista
ORDER BY promedio_dias_entrega;

-- 2. ¿Cual es el costo total de envios por transportista?
SELECT
    transportista,
    ROUND(SUM(costo_envio), 2) AS costo_total_ars
FROM tabla_final
GROUP BY transportista
ORDER BY costo_total_ars DESC;

-- 3. ¿Cuales son las 5 rutas (origen -> destino) con mas envios?
-- (el desempate por nombre hace el resultado estable si hay empates)
SELECT
    origen,
    destino,
    origen || ' -> ' || destino AS ruta,
    COUNT(*)                    AS cantidad_envios
FROM tabla_final
GROUP BY origen, destino
ORDER BY cantidad_envios DESC, origen, destino
LIMIT 5;

-- 4. ¿Cuantos kg se enviaron en total por destino?
SELECT
    destino,
    ROUND(SUM(peso_kg), 2) AS kg_totales
FROM tabla_final
GROUP BY destino
ORDER BY kg_totales DESC;

-- 5. ¿Cuantos envios se entregaron en mas de 7 dias?
SELECT
    COUNT(*) AS envios_mas_de_7_dias
FROM tabla_final
WHERE dias_entrega > 7;
