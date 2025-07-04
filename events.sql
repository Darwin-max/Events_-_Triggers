-- 1. Resumen Diario Único : crear un evento que genere un resumen de ventas 
-- **una sola vez** al finalizar el día de ayer y 
-- luego se elimine automáticamente llamado `ev_resumen_diario_unico`.
DELIMITER //

CREATE EVENT IF NOT EXISTS ev_resumen_diario_unico
ON SCHEDULE AT TIMESTAMP(CURRENT_DATE, '00:05:00') + INTERVAL 1 DAY
ON COMPLETION NOT PRESERVE
DO
BEGIN
    INSERT INTO resumen_ventas (fecha, total_pedidos, total_ingresos)
    SELECT
        DATE(fecha_recogida) AS fecha,
        COUNT(*) AS total_pedidos,
        SUM(total) AS total_ingresos
    FROM pedido
    WHERE DATE(fecha_recogida) = CURRENT_DATE - INTERVAL 1 DAY
    GROUP BY DATE(fecha_recogida);
END;
//

DELIMITER ;

-- 2. Resumen Semanal Recurrente: cada lunes a las 01:00 AM,
-- generar el total de pedidos e ingresos de la semana pasada, **manteniendo** 
-- el evento para que siga ejecutándose cada semana llamado `ev_resumen_semanal`.

DELIMITER //

CREATE EVENT IF NOT EXISTS ev_resumen_semanal
ON SCHEDULE
    EVERY 1 WEEK
    STARTS '2025-06-23 01:00:00'
ON COMPLETION PRESERVE
DO
BEGIN
    INSERT INTO resumen_ventas (fecha, total_pedidos, total_ingresos)
    SELECT
        CURRENT_DATE - INTERVAL 1 DAY,
        COUNT(*),
        SUM(total)
    FROM pedido
    WHERE DATE(fecha_recogida) = CURRENT_DATE - INTERVAL 1 DAY;
END;
//

DELIMITER ;



-- 3. Alerta de Stock Bajo Única: en un futuro arranque del sistema (requerimiento del sistema), 
-- generar una única pasada de alertas (`alerta_stock`) 
-- de ingredientes con stock < 5, y luego autodestruir el evento.

DELIMITER //

CREATE EVENT IF NOT EXISTS ev_alerta_stock_unica
ON SCHEDULE AT '2025-06-30 08:00:00' 
ON COMPLETION NOT PRESERVE
DO
BEGIN
    INSERT INTO alerta_stock (ingrediente_id, stock_actual, fecha_alerta)
    SELECT
        id,
        stock,
        NOW()
    FROM ingrediente
    WHERE stock < 5;
END;
//

DELIMITER ;

-- 4. Monitoreo Continuo de Stock: cada 30 minutos, revisar ingredientes con stock < 10 e insertar alertas en `alerta_stock`,
-- **dejando** el evento activo para siempre llamado `ev_monitor_stock_bajo`.
DELIMITER //

CREATE EVENT IF NOT EXISTS ev_monitor_stock_bajo
ON SCHEDULE
    EVERY 30 MINUTE
    STARTS NOW()
ON COMPLETION PRESERVE
DO
BEGIN
    INSERT INTO alerta_stock (ingrediente_id, stock_actual, fecha_alerta)
    SELECT
        id,
        stock,
        NOW()
    FROM ingrediente
    WHERE stock < 10;
END;
//

DELIMITER ;



-- 5. Limpieza de Resúmenes Antiguos: una sola vez, eliminar de `resumen_ventas` 
-- los registros con fecha anterior a hace 365 días y 
-- luego borrar el evento llamado `ev_purgar_resumen_antiguo`.

DELIMITER //

CREATE EVENT IF NOT EXISTS ev_purgar_resumen_antiguo
ON SCHEDULE AT '2025-06-30 03:00:00'
ON COMPLETION NOT PRESERVE
DO
BEGIN
    DELETE FROM resumen_ventas
    WHERE fecha < CURRENT_DATE - INTERVAL 365 DAY;
END;
//

DELIMITER ;
