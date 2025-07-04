-- Active: 1748978904024@@127.0.0.1@3307@Tigres

INSERT INTO cliente (nombre, telefono, direccion) VALUES
('Juan Pérez', '3111111111', 'Calle 123 #45-67'),
('Ana Gómez', '3122222222', 'Carrera 10 #20-30'),
('Luis Rojas', '3133333333', 'Av. Siempre Viva 742');

INSERT INTO metodo_pago (nombre) VALUES
('Efectivo'),
('Tarjeta de crédito'),
('Nequi'),
('Transferencia');

INSERT INTO tipo_producto (nombre) VALUES
('Bebida'),
('Comida'),
('Postre');

INSERT INTO producto (nombre, tipo_producto_id) VALUES
('Hamburguesa Clásica', 2),
('Gaseosa Cola', 1),
('Malteada Fresa', 1),
('Brownie', 3);

INSERT INTO presentacion (nombre) VALUES
('Pequeña'),
('Mediana'),
('Grande');

INSERT INTO producto_presentacion (producto_id, presentacion_id, precio) VALUES
(1, 2, 12000.00),
(2, 1, 3000.00),
(3, 3, 8000.00),
(4, 2, 6000.00);

INSERT INTO combo (nombre, precio) VALUES
('Combo Hamburguesa', 15000.00),
('Combo Postre', 12000.00);

INSERT INTO combo_producto (combo_id, producto_id) VALUES
(1, 1),
(1, 2),
(2, 4),
(2, 3);

INSERT INTO ingrediente (nombre, stock, precio) VALUES
('Lechuga', 100, 200.00),
('Tomate', 80, 300.00),
('Queso', 50, 1000.00),
('Tocineta', 40, 1500.00);

INSERT INTO pedido (fecha_recogida, total, cliente_id, metodo_pago_id) VALUES
('2025-06-20 12:30:00', 15000.00, 1, 1),
('2025-06-20 13:00:00', 18000.00, 2, 2);

INSERT INTO factura (total, fecha, pedido_id, cliente_id) VALUES
(15000.00, '2025-06-20 12:35:00', 1, 1),
(18000.00, '2025-06-20 13:05:00', 2, 2);

INSERT INTO detalle_pedido (pedido_id, cantidad) VALUES
(1, 1),
(2, 2);

INSERT INTO detalle_pedido_producto (detalle_id, producto_id) VALUES
(1, 1),
(1, 2),
(2, 4);

INSERT INTO detalle_pedido_combo (detalle_id, combo_id) VALUES
(2, 1);

INSERT INTO ingredientes_extra (detalle_id, ingrediente_id, cantidad) VALUES
(1, 3, 2),
(1, 4, 1);

INSERT INTO resumen_ventas (fecha, total_pedidos, total_ingresos) VALUES
('2025-06-20', 2, 33000.00);

INSERT INTO alerta_stock (ingrediente_id, stock_actual, fecha_alerta) VALUES
(3, 5, '2025-06-20 14:00:00'),
(4, 3, '2025-06-20 14:05:00');

INSERT INTO tipo_producto(nombre) VALUES ('Bebida');
INSERT INTO producto(nombre, tipo_producto_id) VALUES ('Cola', 1);
INSERT INTO presentacion(nombre) VALUES ('Botella 500ml');
INSERT INTO producto_presentacion(producto_id, presentacion_id, precio)VALUES (1, 1, 3500);
