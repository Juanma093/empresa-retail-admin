-- =====================================================================
-- Proyecto : empresa-retail-admin
-- Archivo  : 01_esquema.sql
-- Motor    : MySQL 8.0+ (MySQL Workbench)
-- Propósito: Crear la base de datos empresa_retail y sus tablas.
-- Ejecutar : como root (o un usuario con privilegios de administración)
-- =====================================================================

DROP DATABASE IF EXISTS empresa_retail;
CREATE DATABASE empresa_retail
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_spanish_ci;

USE empresa_retail;

-- ---------------------------------------------------------------------
-- Tabla: clientes  (gestionada por Cajas -> ana_crm)
-- ---------------------------------------------------------------------
CREATE TABLE clientes (
  id_cliente      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  documento       VARCHAR(20)  NOT NULL,
  nombres         VARCHAR(60)  NOT NULL,
  apellidos       VARCHAR(60)  NOT NULL,
  email           VARCHAR(100) NOT NULL,
  telefono        VARCHAR(20)  NULL,
  ciudad          VARCHAR(60)  NOT NULL DEFAULT 'Popayán',
  fecha_registro  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  estado          ENUM('activo','inactivo') NOT NULL DEFAULT 'activo',
  CONSTRAINT uq_clientes_documento UNIQUE (documento),
  CONSTRAINT uq_clientes_email     UNIQUE (email)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Tabla: canales  (gestionada por Inventario/Mercadeo -> pedro_mkt)
-- ---------------------------------------------------------------------
CREATE TABLE canales (
  id_canal     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre       VARCHAR(50)  NOT NULL,
  tipo         ENUM('fisico','digital') NOT NULL,
  descripcion  VARCHAR(200) NULL,
  activo       BOOLEAN      NOT NULL DEFAULT TRUE,
  CONSTRAINT uq_canales_nombre UNIQUE (nombre)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Tabla: campanas  (gestionada por Inventario/Mercadeo -> pedro_mkt)
-- ---------------------------------------------------------------------
CREATE TABLE campanas (
  id_campana    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(80)   NOT NULL,
  descripcion   VARCHAR(255)  NULL,
  id_canal      INT UNSIGNED  NOT NULL,
  fecha_inicio  DATE          NOT NULL,
  fecha_fin     DATE          NOT NULL,
  presupuesto   DECIMAL(12,2) NOT NULL DEFAULT 0,
  estado        ENUM('planeada','activa','finalizada') NOT NULL DEFAULT 'planeada',
  CONSTRAINT fk_campanas_canal FOREIGN KEY (id_canal)
    REFERENCES canales (id_canal) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_campanas_fechas      CHECK (fecha_fin >= fecha_inicio),
  CONSTRAINT ck_campanas_presupuesto CHECK (presupuesto >= 0)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Tabla: interacciones  (gestionada por Cajas -> ana_crm)
-- ---------------------------------------------------------------------
CREATE TABLE interacciones (
  id_interaccion  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_cliente      INT UNSIGNED NOT NULL,
  id_canal        INT UNSIGNED NOT NULL,
  tipo            ENUM('consulta','reclamo','venta','soporte','seguimiento') NOT NULL,
  descripcion     VARCHAR(255) NULL,
  fecha           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_interacciones_cliente FOREIGN KEY (id_cliente)
    REFERENCES clientes (id_cliente) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_interacciones_canal FOREIGN KEY (id_canal)
    REFERENCES canales (id_canal) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Tabla: conversiones  (consultada por Gerencia/Auditoría -> marta_auditoria)
-- ---------------------------------------------------------------------
CREATE TABLE conversiones (
  id_conversion  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_cliente     INT UNSIGNED  NOT NULL,
  id_campana     INT UNSIGNED  NULL,
  tipo           ENUM('compra','registro','suscripcion') NOT NULL,
  valor          DECIMAL(12,2) NOT NULL DEFAULT 0,
  fecha          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_conversiones_cliente FOREIGN KEY (id_cliente)
    REFERENCES clientes (id_cliente) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_conversiones_campana FOREIGN KEY (id_campana)
    REFERENCES campanas (id_campana) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT ck_conversiones_valor CHECK (valor >= 0)
) ENGINE = InnoDB;

-- Índices de apoyo para consultas frecuentes
CREATE INDEX ix_interacciones_fecha ON interacciones (fecha);
CREATE INDEX ix_conversiones_tipo   ON conversiones (tipo);
CREATE INDEX ix_conversiones_fecha  ON conversiones (fecha);
