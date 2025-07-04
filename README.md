🧾 1. Estructura General
✨ Esta base de datos está diseñada para gestionar clientes, pedidos, facturación, combos, productos e inventario de una empresa de alimentos. Ideal para practicar triggers, eventos programados y consultas avanzadas.

📊 2. Tablas Principales (Toggle por tabla)
<details> <summary>📌 cliente</summary>
id: INT, PK

nombre: VARCHAR(100)

telefono: VARCHAR(15)

direccion: VARCHAR(150)

</details> <details> <summary>🧾 pedido</summary>
id: INT, PK

fecha_recogida: DATETIME

total: DECIMAL

cliente_id: FK → cliente

metodo_pago_id: FK → metodo_pago

</details> <details> <summary>💸 factura</summary>
id: INT, PK

total: DECIMAL

fecha: DATETIME

pedido_id: FK → pedido

cliente_id: FK → cliente

</details> <details> <summary>🍕 producto</summary>
id: INT, PK

nombre: VARCHAR(100)

tipo_producto_id: FK → tipo_producto

</details> <details> <summary>🧪 ingrediente</summary>
id: INT, PK

nombre: VARCHAR(100)

stock: INT

precio: DECIMAL

</details> <details> <summary>📦 resumen_ventas</summary>
fecha: DATE (PK)

total_pedidos: INT

total_ingresos: DECIMAL

creado_en: DATETIME

</details> <details> <summary>⚠️ alerta_stock</summary>
id: INT, PK

ingrediente_id: FK → ingrediente

stock_actual: INT

fecha_alerta: DATETIME

creado_en: TIMESTAMP

</details>
🛠️ 3. Relaciones Importantes
pedido.cliente_id → cliente.id

factura.pedido_id → pedido.id

producto.tipo_producto_id → tipo_producto.id

ingredientes_extra.ingrediente_id → ingrediente.id

combo_producto.combo_id → combo.id

(Puedes usar diagramas de ERD si Notion tiene integración o añadir como imagen)

🔁 4. Usos Sugeridos
Área	Uso
🔧 Triggers	Auditoría de precios, control de stock, bloqueo de datos inválidos
⏰ Eventos	Generación de reportes automáticos, alertas de stock bajo, limpieza de datos
📈 Vistas / Consultas	Total ventas por día, ingresos por producto, combos más vendidos




🔥 Sección 5: Triggers (con toggle para expandir)
🔐 Validar stock
Evita insertar productos con cantidad < 1.

📉 Descontar stock
Resta stock automáticamente al agregar ingredientes extra.

🕵️ Auditoría de precios
Guarda un historial cuando se actualiza el precio de un producto.

🚫 Bloqueo de precio 0
Impide insertar productos con precios <= 0.

🧾 Factura automática
Crea una factura al insertar un pedido.

✅ Estado del pedido
Marca el pedido como “Facturado” después de la factura.

❌ Bloqueo de eliminación de combos
No permite borrar combos usados en pedidos.

🧹 Limpieza de relaciones
Elimina vínculos asociados al borrar detalles de pedidos.

⚠️ Alerta de stock bajo
Crea una alerta si el stock de un ingrediente baja de 5.

🧑‍💼 Log de clientes
Registra automáticamente cada nuevo cliente insertado.

⏰ Sección 6: Eventos Programados


📌 Requisitos Generales

SET GLOBAL event_scheduler = ON;
SHOW GLOBAL VARIABLES LIKE 'event_scheduler';
Asegúrate de tener habilitado el programador de eventos para que los siguientes eventos funcionen correctamente.

🔁 1. ev_resumen_diario_unico – Resumen Diario Único
🗓 Frecuencia: Ejecuta una sola vez al finalizar el día anterior (a las 00:05 del día siguiente).

🔥 Tipo: Autodestructivo (NOT PRESERVE)

📊 Acción: Inserta un resumen de ventas (pedidos e ingresos) en la tabla resumen_ventas.


ON SCHEDULE AT TIMESTAMP(CURRENT_DATE, '00:05:00') + INTERVAL 1 DAY
🔁 2. ev_resumen_semanal – Resumen Semanal Recurrente
🗓 Frecuencia: Todos los lunes a la 01:00 AM.

🔄 Tipo: Recurrente (PRESERVE)

📊 Acción: Inserta el resumen del domingo anterior en la tabla resumen_ventas.


EVERY 1 WEEK
STARTS '2025-06-23 01:00:00'
⚠️ 3. ev_alerta_stock_unica – Alerta de Stock Bajo Única
🗓 Frecuencia: Una sola vez, en el arranque programado del sistema.

🔥 Tipo: Autodestructivo (NOT PRESERVE)

🚨 Acción: Inserta alertas de ingredientes con stock menor a 5 en alerta_stock.


ON SCHEDULE AT '2025-06-30 08:00:00'
🧪 4. ev_monitor_stock_bajo – Monitoreo Continuo de Stock
⏱ Frecuencia: Cada 30 minutos.

🔄 Tipo: Recurrente (PRESERVE)

🚨 Acción: Monitorea constantemente ingredientes con stock < 10 e inserta en alerta_stock.


EVERY 30 MINUTE
STARTS NOW()
🧹 5. ev_purgar_resumen_antiguo – Limpieza de Resúmenes
🗓 Frecuencia: Una sola vez.

🔥 Tipo: Autodestructivo (NOT PRESERVE)

🧼 Acción: Elimina registros de resumen_ventas con fecha anterior a hace un año.


ON SCHEDULE AT '2025-06-30 03:00:00'
