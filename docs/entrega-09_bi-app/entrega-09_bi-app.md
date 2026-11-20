# Entrega 9 – Aplicación de BI (Metabase)

UNLaM – 3641 Bases de Datos Aplicada – Com. 5600 – Grupo 09

Este documento explica cómo conectar una plataforma de BI a `MundialDB` y qué reportes se presentan.
Plataforma elegida: **Metabase Open Source**

No es una guía de instalación de Metabase: para eso se enlaza su documentación oficial. Acá se documenta lo que
depende de **esta** base de datos y de la configuración de SQL Server.

## 1. Cómo se conecta el BI con la base

```
Metabase  ──TCP/IP (puerto fijo)──▶  SQL Server  ──▶  MundialDB
            login_bi / usr_bi                          esquema bi (solo vistas)
```

- Metabase usa un **login SQL dedicado** que solo pertenece al rol `consulta`.
- `consulta` tiene `SELECT` únicamente sobre el esquema `bi` (vistas definidas en `03_crear_vistas.sql`).

## 2. Requisitos previos

| Requisito | Detalle |
|---|---|
| Base creada | Scripts ejecutados; el rol `consulta` y las vistas `bi.*` tienen que existir. |
| Metabase | Java o Docker, según la documentación vigente de Metabase: <https://www.metabase.com/docs/latest/installation-and-operation/running-the-metabase-jar-file> |
| Permisos | Un usuario con permisos de administración sobre la instancia de SQL Server (para crear el login y cambiar la configuración de red). |

## 3. Configuración de SQL Server

Estos cuatro puntos son independientes de dónde corra Metabase.

### 3.1 Habilitar TCP/IP y fijar el puerto
Metabase se conecta por TCP. En una instancia con nombre (por ejemplo SQL Server Express, `SQLEXPRESS`) el puerto es dinámico
por defecto, lo que impide configurar una conexión estable.

En *SQL Server Configuration Manager* → *SQL Server Network Configuration* → *Protocols for \<instancia\>*:
1. Habilitar **TCP/IP**.
2. En *Properties* → pestaña *IP Addresses* → sección **IPAll**: dejar vacío *TCP Dynamic Ports* y poner un puerto fijo
   en *TCP Port* (1433 si está libre).
3. **Reiniciar el servicio** de SQL Server, para aplicar los cambios. Esto es crítico en cualquier cambio que se realice sobre la configuración del servidor.

### 3.2 Habilitar autenticación de SQL Server (modo mixto)
Metabase se conecta con un login SQL, no con una cuenta de Windows. En SSMS: *Propiedades del servidor* → *Seguridad* →
**SQL Server and Windows Authentication mode**, y reiniciar el servicio.

### 3.3 Permitir la conexión en el firewall
- Si Metabase corre en la misma máquina que SQL Server por loopback (`localhost` o 127.0.0.1), no hace falta tocar el firewall.
- Si corre en otra máquina, en una máquina virtual, en un contenedor o en WSL2, hay que permitir la **entrada TCP al puerto elegido**
  y limitarla a la red necesaria (perfil privado o red local). No exponer el puerto a redes públicas.

### 3.4 Login y usuario
El **login** es un objeto del servidor (se guarda en `master`) y el **usuario** es un objeto de la base `MundialDB`.
La contraseña la define quien instale el sistema y **no se versiona** (el repositorio es público).

```sql
USE master;
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_bi')
    CREATE LOGIN login_bi WITH PASSWORD = '<CONTRASEÑA>', CHECK_POLICY = ON;
GO
USE MundialDB;
GO
IF DATABASE_PRINCIPAL_ID(N'usr_bi') IS NULL
    CREATE USER usr_bi FOR LOGIN login_bi;
IF IS_ROLEMEMBER(N'rol_consulta', N'usr_bi') = 0
    ALTER ROLE rol_consulta ADD MEMBER usr_bi;
GO
```

Notas:
- Reemplazar `<CONTRASEÑA>` por una clave que cumpla la política de contraseñas de Windows (`CHECK_POLICY = ON`).
- No agregar el usuario a otros roles: darían acceso a las tablas, incluidas las columnas cifradas.
- Si se elimina y se recrea `MundialDB`, el login sobrevive (está en `master`) pero el usuario no: volver a ejecutar solo la segunda parte.

**Verificación** (con un usuario administrador, impersonando al usuario de BI):
```sql
EXECUTE AS USER = 'usr_bi';
SELECT TOP (1) * FROM bi.vw_partido;      -- debe devolver filas
SELECT TOP (1) * FROM torneo.jugador;     -- debe fallar con error 229 (permiso denegado)
REVERT;
```

## 4. Conexión desde Metabase

*Admin* → *Databases* → *Add database* → **SQL Server**:

| Campo | Valor |
|---|---|
| Host | Dirección de la máquina donde corre SQL Server |
| Port | El puerto fijo del punto 3.1 |
| Database name | `MundialDB` |
| Instance name | Vacío (se conecta por puerto) |
| Username / Password | `login_bi` y la contraseña definida en 3.4 |