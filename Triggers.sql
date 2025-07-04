-- 1. Validar stock antes de agregar detalle de producto (Trigger `BEFORE INSERT`).
DELIMITER $$
CREATE TRIGGER trg_before_insert_detalle
    BEFORE INSERT ON detalle_pedido
    FOR EACH ROW
BEGIN
    IF NEW.cantidad < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cantidad debe ser al menos 1';
    END IF;
END $$

DELIMITER ;

INSERT INTO detalle_pedido (pedido_id, cantidad)VALUES (1, 0);


-- 2. Registrar auditoría de cambios de precio (Trigger `AFTER UPDATE`).

DELIMITER $$

DROP TRIGGER IF EXISTS trg_after_update_precio $$

CREATE TRIGGER trg_after_update_precio
AFTER UPDATE ON producto_presentacion
FOR EACH ROW
BEGIN
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO auditoria_precio (
            producto_id,
            presentacion_id,
            precio_antiguo,
            precio_nuevo
        ) VALUES (
            NEW.producto_id,
            NEW.presentacion_id,
            OLD.precio,
            NEW.precio
        );
    END IF;
END $$
DELIMITER ;

UPDATE producto_presentacion SET precio = 4000 WHERE producto_id = 1 AND presentacion_id = 1;

SELECT * FROM auditoria_precio;

-- 3. Descontar stock tras agregar ingredientes extra (Trigger `AFTER INSERT`).

DELIMITER $$

CREATE TRIGGER trg_after_insert_ingredientes_extra
AFTER INSERT ON ingredientes_extra
FOR EACH ROW
BEGIN
    DECLARE stock_actual INT;

    SELECT stock INTO stock_actual
    FROM ingrediente
    WHERE id = NEW.ingrediente_id;

    IF stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para este ingrediente.';
    END IF;

    UPDATE ingrediente
    SET stock = stock - NEW.cantidad
    WHERE id = NEW.ingrediente_id;
END $$

DELIMITER ;

INSERT INTO ingredientes_extra (detalle_id, ingrediente_id, cantidad)VALUES (1, 2, 1);

-- 4. Impedir precio cero o negativo (Trigger `BEFORE UPDATE`).

DELIMITER $$

DROP TRIGGER IF EXISTS  trg_before_update_precio

CREATE TRIGGER trg_before_update_precio
BEFORE UPDATE ON producto_presentacion
FOR EACH ROW
BEGIN
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio debe ser mayor a cero.';
    END IF;
END $$
DELIMITER ;

UPDATE producto_presentacion SET precio = 0 WHERE producto_id = 1 AND presentacion_id = 1;


-- 5. Evitar eliminación de combos en uso (Trigger `BEFORE DELETE`).

DELIMITER $$
CREATE TRIGGER trg_before_delete_combo
BEFORE DELETE ON combo
FOR EACH ROW
BEGIN
    DECLARE combo_usado INT;

    SELECT COUNT(*) INTO combo_usado
    FROM detalle_pedido_combo
    WHERE combo_id = OLD.id;

    IF combo_usado > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar el combo';
    END IF;
END $$
DELIMITER ;

DELETE FROM combo WHERE id = 1;

-- 6. Limpiar relaciones tras borrar un detalle (Trigger `BEFORE DELETE`).

DELIMITER $$
DROP TRIGGER IF EXISTS trg_after_delete_detalle;
CREATE TRIGGER trg_after_delete_detalle
AFTER DELETE ON detalle_pedido
FOR EACH ROW
BEGIN
    DELETE FROM ingredientes_extra
    WHERE detalle_id = OLD.id;

    DELETE FROM detalle_pedido_producto
    WHERE detalle_id = OLD.id;

    DELETE FROM detalle_pedido_combo
    WHERE detalle_id = OLD.id;
END $$
DELIMITER ;

DELETE FROM detalle_pedido WHERE id = 1;


-- 7. Generar factura automática (Trigger `AFTER INSERT`).

DELIMITER $$
CREATE TRIGGER trg_after_insert_pedido
AFTER INSERT ON pedido
FOR EACH ROW
BEGIN
    INSERT INTO factura (
        total,
        fecha,
        pedido_id,
        cliente_id
    )
    VALUES (
        NEW.total,
        NOW(),
        NEW.id,
        NEW.cliente_id
    );
END $$
DELIMITER ;

INSERT INTO pedido (fecha_recogida, total, cliente_id, metodo_pago_id)
VALUES (NOW(), 28000, 1, 1);

SELECT * FROM factura;


-- 8. Actualizar estado de pedido tras facturar (Trigger `AFTER INSERT`).
DELIMITER $$
CREATE TRIGGER trg_after_insert_factura
AFTER INSERT ON factura
FOR EACH ROW
BEGIN
    UPDATE pedido
    SET estado = 'Facturado'
    WHERE id = NEW.pedido_id;
END $$
DELIMITER ;

INSERT INTO pedido (fecha_recogida, total, cliente_id, metodo_pago_id) VALUES (NOW(), 15000, 1, 1);


-- 9. Control de stock mínimo tras actualización (Trigger `AFTER UPDATE`).
DELIMITER $$
CREATE TRIGGER trg_after_update_stock
AFTER UPDATE ON ingrediente
FOR EACH ROW
BEGIN
    DECLARE stock_minimo INT DEFAULT 5;
    IF NEW.stock < stock_minimo AND OLD.stock >= stock_minimo THEN
        INSERT INTO alerta_stock (
            ingrediente_id,
            stock_actual,
            fecha_alerta
        )
        VALUES (
            NEW.id,
            NEW.stock,
            NOW()
        );
    END IF;
END $$
DELIMITER ;

-- 10. Registrar creación de nuevos clientes (Trigger `AFTER INSERT`).

DELIMITER $$
CREATE TRIGGER trg_after_insert_cliente
AFTER INSERT ON cliente
FOR EACH ROW
BEGIN
    INSERT INTO registro_clientes (
        cliente_id,
        nombre,
        telefono
    ) VALUES (
        NEW.id,
        NEW.nombre,
        NEW.telefono
    );
END $$
DELIMITER ;

INSERT INTO cliente (nombre, telefono, direccion) VALUES ('Pepe', '3111234567', 'Calle 99 #45-67');
