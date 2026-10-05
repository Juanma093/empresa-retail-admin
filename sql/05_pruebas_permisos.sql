-- =====================================================================
-- Proyecto : empresa-retail-admin
-- Archivo  : 05_pruebas_permisos.sql
-- Propósito: Validar que cada usuario solo pueda hacer lo que su rol permite.
-- Cómo usar: En MySQL Workbench cree una conexión por usuario
--            (Hostname 127.0.0.1 / localhost, Port 3306) y ejecute
--            SOLO el bloque correspondiente a ese usuario.
--            ✔ = debe funcionar   ✘ = debe fallar (Error 1142 / 1370)
-- =====================================================================

-- =====================================================================
-- BLOQUE A: conectado como ana_crm  (contraseña: Retail2026!Caja)
-- =====================================================================
USE empresa_retail;
SELECT CURRENT_USER(), CURRENT_ROLE();                        -- ✔ rol_ana

SELECT * FROM clientes;                                       -- ✔
INSERT INTO clientes (documento, nombres, apellidos, email)
VALUES ('1061000099', 'Prueba', 'Cajas', 'prueba.caja@correo.com'); -- ✔
UPDATE clientes SET telefono = '3009998877'
WHERE documento = '1061000099';                               -- ✔
SELECT * FROM interacciones;                                  -- ✔
INSERT INTO interacciones (id_cliente, id_canal, tipo, descripcion)
VALUES (1, 1, 'venta', 'Prueba de permisos ana_crm');         -- ✔
DELETE FROM interacciones WHERE descripcion = 'Prueba de permisos ana_crm'; -- ✔
DELETE FROM clientes WHERE documento = '1061000099';          -- ✔

SELECT * FROM campanas;                                       -- ✘ 1142
SELECT * FROM conversiones;                                   -- ✘ 1142
CALL sp_resumen_conversiones();                               -- ✘ 1370

-- =====================================================================
-- BLOQUE B: conectado como pedro_mkt  (contraseña: Retail2026!Stock)
-- =====================================================================
USE empresa_retail;
SELECT CURRENT_USER(), CURRENT_ROLE();                        -- ✔ rol_pedro

SELECT * FROM canales;                                        -- ✔
INSERT INTO canales (nombre, tipo, descripcion)
VALUES ('Marketplace', 'digital', 'Canal de prueba');         -- ✔
SELECT * FROM campanas;                                       -- ✔
UPDATE campanas SET presupuesto = 5500000
WHERE nombre = 'Black Friday 2026';                           -- ✔
DELETE FROM canales WHERE nombre = 'Marketplace';             -- ✔
SELECT * FROM clientes;                                       -- ✔ (solo lectura)

UPDATE clientes SET ciudad = 'Cali' WHERE id_cliente = 1;     -- ✘ 1142
INSERT INTO clientes (documento, nombres, apellidos, email)
VALUES ('1', 'X', 'Y', 'x@y.com');                            -- ✘ 1142
DELETE FROM clientes WHERE id_cliente = 1;                    -- ✘ 1142
SELECT * FROM interacciones;                                  -- ✘ 1142
SELECT * FROM conversiones;                                   -- ✘ 1142

-- =====================================================================
-- BLOQUE C: conectado como marta_auditoria  (contraseña: Retail2026!Admin)
-- =====================================================================
USE empresa_retail;
SELECT CURRENT_USER(), CURRENT_ROLE();                        -- ✔ rol_marta

SELECT * FROM conversiones;                                   -- ✔
SELECT * FROM conversiones WHERE tipo = 'compra';             -- ✔
CALL sp_resumen_conversiones();                               -- ✔
CALL sp_conversiones_por_campana();                           -- ✔
CALL sp_conversiones_por_fecha('2026-05-01', '2026-06-30');   -- ✔
CALL sp_conversiones_por_tipo('suscripcion');                 -- ✔

INSERT INTO conversiones (id_cliente, tipo, valor)
VALUES (1, 'compra', 1000);                                   -- ✘ 1142
UPDATE conversiones SET valor = 0 WHERE id_conversion = 1;    -- ✘ 1142
DELETE FROM conversiones WHERE id_conversion = 1;             -- ✘ 1142
SELECT * FROM clientes;                                       -- ✘ 1142
SELECT * FROM campanas;                                       -- ✘ 1142
