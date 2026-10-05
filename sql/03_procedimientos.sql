-- =====================================================================
-- Proyecto : empresa-retail-admin
-- Archivo  : 03_procedimientos.sql
-- Propósito: Procedimientos almacenados de CONSULTA (solo lectura)
--            que podrá ejecutar el rol de Gerencia/Auditoría (marta).
-- Ejecutar : como root, después de 02_datos_prueba.sql
-- Nota     : SQL SECURITY DEFINER hace que el procedimiento se ejecute
--            con los privilegios de quien lo creó (root). Así marta
--            obtiene los reportes SIN tener SELECT sobre las tablas base.
-- =====================================================================

USE empresa_retail;

DROP PROCEDURE IF EXISTS sp_resumen_conversiones;
DROP PROCEDURE IF EXISTS sp_conversiones_por_campana;
DROP PROCEDURE IF EXISTS sp_conversiones_por_fecha;
DROP PROCEDURE IF EXISTS sp_conversiones_por_tipo;

DELIMITER $$

-- 1) Resumen general: cantidad y valor total por tipo de conversión
CREATE PROCEDURE sp_resumen_conversiones()
  READS SQL DATA
  SQL SECURITY DEFINER
  COMMENT 'Resumen de conversiones agrupadas por tipo'
BEGIN
  SELECT tipo,
         COUNT(*)   AS total_conversiones,
         SUM(valor) AS valor_total
  FROM conversiones
  GROUP BY tipo
  ORDER BY total_conversiones DESC;
END $$

-- 2) Rendimiento de cada campaña (incluye canal)
CREATE PROCEDURE sp_conversiones_por_campana()
  READS SQL DATA
  SQL SECURITY DEFINER
  COMMENT 'Conversiones y valor generado por campaña'
BEGIN
  SELECT COALESCE(ca.nombre, 'Sin campaña') AS campana,
         COALESCE(cn.nombre, '-')           AS canal,
         COUNT(co.id_conversion)            AS total_conversiones,
         COALESCE(SUM(co.valor), 0)         AS valor_total
  FROM conversiones co
  LEFT JOIN campanas ca ON ca.id_campana = co.id_campana
  LEFT JOIN canales  cn ON cn.id_canal   = ca.id_canal
  GROUP BY ca.nombre, cn.nombre
  ORDER BY valor_total DESC;
END $$

-- 3) Conversiones en un rango de fechas
CREATE PROCEDURE sp_conversiones_por_fecha(IN p_inicio DATE, IN p_fin DATE)
  READS SQL DATA
  SQL SECURITY DEFINER
  COMMENT 'Conversiones entre dos fechas (inclusive)'
BEGIN
  IF p_inicio IS NULL OR p_fin IS NULL OR p_fin < p_inicio THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Rango de fechas inválido';
  END IF;

  SELECT co.id_conversion, co.tipo, co.valor, co.fecha,
         COALESCE(ca.nombre, 'Sin campaña') AS campana
  FROM conversiones co
  LEFT JOIN campanas ca ON ca.id_campana = co.id_campana
  WHERE co.fecha >= p_inicio
    AND co.fecha <  DATE_ADD(p_fin, INTERVAL 1 DAY)
  ORDER BY co.fecha;
END $$

-- 4) Filtrar por tipo: 'compra', 'registro' o 'suscripcion'
CREATE PROCEDURE sp_conversiones_por_tipo(IN p_tipo VARCHAR(20))
  READS SQL DATA
  SQL SECURITY DEFINER
  COMMENT 'Conversiones de un tipo específico'
BEGIN
  IF p_tipo NOT IN ('compra','registro','suscripcion') THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Tipo inválido: use compra, registro o suscripcion';
  END IF;

  SELECT id_conversion, id_campana, tipo, valor, fecha
  FROM conversiones
  WHERE tipo = p_tipo
  ORDER BY fecha;
END $$

DELIMITER ;
