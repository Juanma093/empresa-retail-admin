-- =====================================================================
-- Proyecto : empresa-retail-admin
-- Archivo  : 02_datos_prueba.sql
-- Propósito: Insertar datos de prueba (ficticios) en empresa_retail.
-- Ejecutar : como root, después de 01_esquema.sql
-- =====================================================================

USE empresa_retail;

INSERT INTO clientes (documento, nombres, apellidos, email, telefono, ciudad) VALUES
  ('1061000001', 'Laura',    'Muñoz',    'laura.munoz@correo.com',    '3101112233', 'Popayán'),
  ('1061000002', 'Carlos',   'Ruiz',     'carlos.ruiz@correo.com',    '3112223344', 'Popayán'),
  ('1061000003', 'Valentina','Gómez',    'valentina.gomez@correo.com','3123334455', 'Cali'),
  ('1061000004', 'Andrés',   'Paz',      'andres.paz@correo.com',     '3134445566', 'Pasto'),
  ('1061000005', 'Sofía',    'Ordóñez',  'sofia.ordonez@correo.com',  '3145556677', 'Popayán');

INSERT INTO canales (nombre, tipo, descripcion) VALUES
  ('Tienda física',   'fisico',  'Punto de venta principal - Centro'),
  ('Tienda en línea', 'digital', 'Comercio electrónico propio'),
  ('Redes sociales',  'digital', 'Instagram, Facebook y TikTok'),
  ('Correo',          'digital', 'Campañas de email marketing'),
  ('WhatsApp',        'digital', 'Atención y ventas por WhatsApp Business');

INSERT INTO campanas (nombre, descripcion, id_canal, fecha_inicio, fecha_fin, presupuesto, estado) VALUES
  ('Regreso a clases 2026', 'Descuentos en útiles escolares',     2, '2026-01-10', '2026-02-15', 2500000, 'finalizada'),
  ('Día de la Madre',       'Combos y bonos de regalo',           3, '2026-04-20', '2026-05-10', 3200000, 'finalizada'),
  ('Club de fidelización',  'Registro al programa de puntos',     4, '2026-06-01', '2026-12-31', 1800000, 'activa'),
  ('Black Friday 2026',     'Ofertas de temporada',               2, '2026-11-20', '2026-11-30', 5000000, 'planeada');

INSERT INTO interacciones (id_cliente, id_canal, tipo, descripcion, fecha) VALUES
  (1, 1, 'venta',       'Compra en caja 2',                          '2026-02-01 10:15:00'),
  (2, 5, 'consulta',    'Pregunta por disponibilidad de producto',   '2026-03-05 16:40:00'),
  (3, 2, 'reclamo',     'Pedido en línea llegó incompleto',          '2026-05-08 09:20:00'),
  (3, 5, 'seguimiento', 'Se confirma reposición del producto',       '2026-05-09 11:00:00'),
  (4, 3, 'consulta',    'Consulta sobre la campaña Día de la Madre', '2026-05-02 18:30:00'),
  (5, 1, 'soporte',     'Cambio de producto por talla',              '2026-07-12 14:05:00');

INSERT INTO conversiones (id_cliente, id_campana, tipo, valor, fecha) VALUES
  (1, 1,    'compra',      185000, '2026-02-01 10:20:00'),
  (2, NULL, 'registro',         0, '2026-03-05 16:50:00'),
  (3, 2,    'compra',      320000, '2026-05-07 20:10:00'),
  (4, 2,    'compra',       95000, '2026-05-03 12:00:00'),
  (5, 3,    'suscripcion',  30000, '2026-06-15 08:45:00'),
  (1, 3,    'registro',         0, '2026-06-20 19:30:00'),
  (2, 3,    'suscripcion',  30000, '2026-07-01 09:00:00');
