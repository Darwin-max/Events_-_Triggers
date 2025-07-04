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