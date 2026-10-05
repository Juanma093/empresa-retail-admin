-- =====================================================================
-- Proyecto : empresa-retail-admin
-- Archivo  : 04_roles_usuarios.sql
-- Propósito: Crear roles, usuarios y asignar permisos (mínimo privilegio)
--
--   Área        Rol          Usuario            Contraseña
--   ----------  -----------  -----------------  -----------------
--   Cajas       rol_ana      ana_crm            Retail2026!Caja
--   Inventario  rol_pedro    pedro_mkt          Retail2026!Stock
--   Gerencia    rol_marta    marta_auditoria    Retail2026!Admin
--
-- Ejecutar : como root, después de 03_procedimientos.sql
-- Requiere : MySQL 8.0.19 o superior (roles + bloqueo por intentos)
-- =====================================================================

USE empresa_retail;

-- ---------------------------------------------------------------------
-- 0. Limpieza (permite volver a ejecutar el script sin errores)
-- ---------------------------------------------------------------------
DROP USER IF EXISTS 'ana_crm'@'localhost',
                    'pedro_mkt'@'localhost',
                    'marta_auditoria'@'localhost';
DROP ROLE IF EXISTS 'rol_ana', 'rol_pedro', 'rol_marta';

-- ---------------------------------------------------------------------
-- 1. Creación de roles
-- ---------------------------------------------------------------------
CREATE ROLE 'rol_ana', 'rol_pedro', 'rol_marta';

-- ---------------------------------------------------------------------
-- 2. Permisos por rol
-- ---------------------------------------------------------------------

-- rol_ana (Cajas): gestiona Clientes e Interacciones (lectura y escritura)
GRANT SELECT, INSERT, UPDATE, DELETE ON empresa_retail.clientes      TO 'rol_ana';
GRANT SELECT, INSERT, UPDATE, DELETE ON empresa_retail.interacciones TO 'rol_ana';

-- rol_pedro (Inventario/Mercadeo): gestiona Canales y Campañas,
-- y solo puede VER clientes (sin INSERT/UPDATE/DELETE)
GRANT SELECT, INSERT, UPDATE, DELETE ON empresa_retail.canales  TO 'rol_pedro';
GRANT SELECT, INSERT, UPDATE, DELETE ON empresa_retail.campanas TO 'rol_pedro';
GRANT SELECT                         ON empresa_retail.clientes TO 'rol_pedro';

-- rol_marta (Gerencia/Auditoría): solo ve Conversiones y ejecuta
-- los procedimientos almacenados de consulta
GRANT SELECT ON empresa_retail.conversiones TO 'rol_marta';
GRANT EXECUTE ON PROCEDURE empresa_retail.sp_resumen_conversiones     TO 'rol_marta';
GRANT EXECUTE ON PROCEDURE empresa_retail.sp_conversiones_por_campana TO 'rol_marta';
GRANT EXECUTE ON PROCEDURE empresa_retail.sp_conversiones_por_fecha   TO 'rol_marta';
GRANT EXECUTE ON PROCEDURE empresa_retail.sp_conversiones_por_tipo    TO 'rol_marta';

-- ---------------------------------------------------------------------
-- 3. Creación de usuarios
--    - FAILED_LOGIN_ATTEMPTS 3 / PASSWORD_LOCK_TIME 1: bloquea la cuenta
--      1 día tras 3 intentos fallidos (protección contra fuerza bruta).
--    - PASSWORD EXPIRE INTERVAL 90 DAY: obliga a renovar la contraseña.
-- ---------------------------------------------------------------------
CREATE USER 'ana_crm'@'localhost'
  IDENTIFIED BY 'Retail2026!Caja'
  FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 1
  PASSWORD EXPIRE INTERVAL 90 DAY;

CREATE USER 'pedro_mkt'@'localhost'
  IDENTIFIED BY 'Retail2026!Stock'
  FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 1
  PASSWORD EXPIRE INTERVAL 90 DAY;

CREATE USER 'marta_auditoria'@'localhost'
  IDENTIFIED BY 'Retail2026!Admin'
  FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 1
  PASSWORD EXPIRE INTERVAL 90 DAY;

-- ---------------------------------------------------------------------
-- 4. Asignación de roles a usuarios y activación por defecto
-- ---------------------------------------------------------------------
GRANT 'rol_ana'   TO 'ana_crm'@'localhost';
GRANT 'rol_pedro' TO 'pedro_mkt'@'localhost';
GRANT 'rol_marta' TO 'marta_auditoria'@'localhost';

-- Sin esto el rol queda asignado pero INACTIVO al iniciar sesión
SET DEFAULT ROLE 'rol_ana'   TO 'ana_crm'@'localhost';
SET DEFAULT ROLE 'rol_pedro' TO 'pedro_mkt'@'localhost';
SET DEFAULT ROLE 'rol_marta' TO 'marta_auditoria'@'localhost';

FLUSH PRIVILEGES;

-- ---------------------------------------------------------------------
-- 5. Verificación (como root)
-- ---------------------------------------------------------------------
SHOW GRANTS FOR 'rol_ana';
SHOW GRANTS FOR 'rol_pedro';
SHOW GRANTS FOR 'rol_marta';

SHOW GRANTS FOR 'ana_crm'@'localhost'         USING 'rol_ana';
SHOW GRANTS FOR 'pedro_mkt'@'localhost'       USING 'rol_pedro';
SHOW GRANTS FOR 'marta_auditoria'@'localhost' USING 'rol_marta';

SELECT user, host, account_locked, password_lifetime
FROM mysql.user
WHERE user IN ('ana_crm','pedro_mkt','marta_auditoria');
