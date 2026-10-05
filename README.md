# empresa-retail-admin

Configuración de seguridad para la base de datos **empresa_retail** en MySQL 8, dividiendo las responsabilidades entre el personal de **Cajas**, **Inventario** y **Gerencia** mediante roles, usuarios y permisos bajo el principio de **mínimo privilegio**.

> Proyecto académico — Ingeniería de Sistemas, Fundación Universitaria de Popayán (FUP).
> Autor: Juan Manuel Ordóñez ([@Juanma093](https://github.com/Juanma093))

---

## Objetivo

Configurar la seguridad de la base de datos `empresa_retail` para que cada área solo acceda a la información que necesita para su trabajo.

## Modelo de datos

| Tabla | Descripción |
|---|---|
| `clientes` | Datos de los clientes de la tienda |
| `interacciones` | Contactos con el cliente (venta, consulta, reclamo, soporte, seguimiento) |
| `canales` | Canales de venta/comunicación (tienda física, en línea, redes, correo, WhatsApp) |
| `campanas` | Campañas de mercadeo asociadas a un canal |
| `conversiones` | Resultados: **compra**, **registro** o **suscripción** |

## Roles, usuarios y permisos

| Área | Rol | Usuario | Permisos |
|---|---|---|---|
| Cajas | `rol_ana` | `ana_crm` | `SELECT, INSERT, UPDATE, DELETE` en `clientes` e `interacciones` |
| Inventario / Mercadeo | `rol_pedro` | `pedro_mkt` | `SELECT, INSERT, UPDATE, DELETE` en `canales` y `campanas`; solo `SELECT` en `clientes` |
| Gerencia / Auditoría | `rol_marta` | `marta_auditoria` | Solo `SELECT` en `conversiones` y `EXECUTE` en los procedimientos de consulta |

Medidas adicionales en las cuentas: bloqueo de 1 día tras 3 intentos fallidos (`FAILED_LOGIN_ATTEMPTS`) y expiración de contraseña cada 90 días.

### Procedimientos almacenados de consulta (`SQL SECURITY DEFINER`)

| Procedimiento | Uso |
|---|---|
| `sp_resumen_conversiones()` | Total y valor por tipo de conversión |
| `sp_conversiones_por_campana()` | Rendimiento por campaña y canal |
| `sp_conversiones_por_fecha(inicio, fin)` | Conversiones en un rango de fechas |
| `sp_conversiones_por_tipo(tipo)` | Filtra por `compra`, `registro` o `suscripcion` |

## Estructura del repositorio

```
empresa-retail-admin/
├── README.md
├── .gitignore
├── sql/
│   ├── 01_esquema.sql            # Base de datos y tablas
│   ├── 02_datos_prueba.sql       # Datos ficticios
│   ├── 03_procedimientos.sql     # Procedimientos de consulta
│   ├── 04_roles_usuarios.sql     # Roles, usuarios y GRANT
│   └── 05_pruebas_permisos.sql   # Pruebas por usuario (✔ / ✘)
└── docs/
    └── Documento_Tecnico_Empresa_Retail.docx
```

## Ejecución

Requisitos: MySQL Server 8.0.19+ y MySQL Workbench (probado en Linux Mint / Ubuntu).

1. Conectarse como `root` en MySQL Workbench.
2. Ejecutar en orden: `01_esquema.sql` → `02_datos_prueba.sql` → `03_procedimientos.sql` → `04_roles_usuarios.sql`.
3. Crear una conexión por usuario (`127.0.0.1:3306`) y ejecutar el bloque correspondiente de `05_pruebas_permisos.sql`.

Desde terminal:

```bash
cd sql
for f in 01_esquema.sql 02_datos_prueba.sql 03_procedimientos.sql 04_roles_usuarios.sql; do
  sudo mysql -u root < "$f"
done
```

## Ramas

| Rama | Uso |
|---|---|
| `main` | Rama estable (estructura base: README y .gitignore) |
| `develop` | Solución completa de la actividad |

## Nota de seguridad

Las contraseñas aparecen en los scripts únicamente porque el enunciado de la actividad las define. En un entorno real se gestionarían con variables de entorno o un gestor de secretos y nunca se versionarían.
