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