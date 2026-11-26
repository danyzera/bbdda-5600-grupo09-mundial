# Entrega 9 – Aplicación de gestión (C#)

UNLaM – 3641 Bases de Datos Aplicada – Com. 5600 – Grupo 09

Este documento explica cómo configurar y ejecutar una aplicación de consola desarrollada en C# para gestionar jugadores de `MundialDB` mediante procedimientos almacenados.

Tecnologías utilizadas: **C# / .NET 10 / Microsoft.Data.SqlClient**.

No es una guía de instalación de SQL Server ni del entorno .NET: para eso se enlaza la documentación oficial. Acá se documenta lo que depende de **esta** base de datos y de la configuración necesaria para ejecutar la aplicación.

## 0. ¿Por qué C#?

Microsoft provee, para el ecosistema .NET (*al que pertenece C#*), el proveedor de datos `Microsoft.Data.SqlClient`. Este facilita mucho la comunicación entre la aplicación y la BD; provee abstracciones para la conexión per se, comandos, consultas parametrizadas, **ejecución de SPs** (núcleo de la app, ya que como se dice en la consigna nada accede directo a las tablas, sino que se hace mediante los SPs de ABM).

## 1. Cómo se conecta la aplicación con la base

- La aplicación utiliza `Microsoft.Data.SqlClient`, el proveedor de acceso a datos de .NET para SQL Server.
- Las operaciones se ejecutan mediante procedimientos almacenados del esquema `torneo`, sin manipulación directa de las tablas desde la aplicación.
- La cadena de conexión se obtiene mediante la variable de entorno `MUNDIAL_CS`, evitando incluir credenciales o configuraciones particulares de cada instalación en el código fuente.

Procedimientos utilizados:

| Operación | Procedimiento almacenado |
|---|---|
| Alta | `torneo.sp_jugador_alta` |
| Modificación | `torneo.sp_jugador_modificacion` |
| Baja | `torneo.sp_jugador_baja` |

## 2. Requisitos previos

| Requisito | Detalle |
|---|---|
| Base de datos | `MundialDB` debe estar creada y desplegada, incluyendo el esquema `torneo` y los tres procedimientos almacenados utilizados por la aplicación. |
| SQL Server | Una instancia activa y accesible de SQL Server. |
| .NET SDK | .NET 10 SDK, necesario para compilar y ejecutar el proyecto, cuyo framework objetivo es `net10.0`. |
| Microsoft.Data.SqlClient | Dependencia NuGet declarada en el archivo `.csproj`. Se restaura junto con las demás dependencias del proyecto. |
| Permisos | La identidad utilizada por la conexión debe tener acceso a la base y permiso `EXECUTE` sobre los procedimientos almacenados correspondientes. |

Documentación oficial:

- [.NET 10 – Descargas](https://dotnet.microsoft.com/download/dotnet/10.0).
- [.NET – Instalación en Windows](https://learn.microsoft.com/en-us/dotnet/core/install/windows).
- [Microsoft.Data.SqlClient – NuGet](https://www.nuget.org/packages/Microsoft.Data.SqlClient/).
- [Microsoft.Data.SqlClient – Documentación](https://learn.microsoft.com/en-us/sql/connect/ado-net/microsoft-ado-net-sql-server).

**Nota:** No es necesario instalar Visual Studio ni un controlador ODBC. El SDK de .NET y una terminal son suficientes para compilar y ejecutar la aplicación.

## 3. Configuración de SQL Server

Estos puntos dependen de dónde se ejecute la aplicación y del mecanismo de autenticación elegido.

### 3.1 Habilitar TCP/IP y fijar el puerto (solo conexiones remotas)

Si la aplicación se ejecuta en la misma máquina que SQL Server, utilizando una instancia local (por ejemplo, `.\SQLEXPRESS`), no es necesario configurar TCP/IP ni modificar el firewall para establecer la conexión local.

Si la aplicación se ejecuta desde otra máquina, es necesario habilitar la comunicación TCP/IP.

En *SQL Server Configuration Manager* → *SQL Server Network Configuration* → *Protocols for \<instancia\>*:

1. Habilitar **TCP/IP**.
2. En *Properties* → pestaña *IP Addresses* → sección **IPAll**: dejar vacío *TCP Dynamic Ports* y establecer un puerto fijo en *TCP Port* (1433 si está disponible).
3. **Reiniciar el servicio** de SQL Server para aplicar los cambios.

Si la conexión es remota, también debe habilitarse el tráfico TCP entrante al puerto elegido en el firewall, restringiendo el acceso a la red necesaria.

### 3.2 Autenticación

La aplicación no impone un mecanismo de autenticación específico: este se determina mediante la cadena de conexión.

Si se opta por autenticación de SQL Server, será necesario habilitar el modo mixto (*SQL Server and Windows Authentication mode*) y utilizar un login SQL con su correspondiente usuario en la base de datos. Ejemplo sugerido de login:

```sql
USE master;
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_app_abm')
    CREATE LOGIN login_app_abm WITH PASSWORD = '<definida-localmente>', CHECK_POLICY = ON;
GO
USE MundialDB;
GO
IF DATABASE_PRINCIPAL_ID(N'usr_app_abm') IS NULL
    CREATE USER usr_app_abm FOR LOGIN login_app_abm;
IF IS_ROLEMEMBER(N'administrador', N'usr_app_abm') = 0
    ALTER ROLE administrador ADD MEMBER usr_app_abm;
GO
```

Recuérdese que el login se crea contra master, y el usuario como se ve en la porción de código anterior será usando MundialDB. Esto infiere, también, que si se reconstruye la base de datos tras usar una vez la aplicación con este login, *solo habrá que ejecutar la segunda parte, que crea el usuario, porque el login sobrevive en master*.

> Nótese que esta sección es idéntica a cómo se gestiona el login para usar Metabase con MundialDB.

## 4. Conexión desde la aplicación

La aplicación obtiene la cadena de conexión de la variable de entorno `MUNDIAL_CS`. La variable de entorno debe estar definida en la misma sesión de terminal desde la cual se ejecutará la aplicación.

```powershell
$env:MUNDIAL_CS = "Server=localhost;Database=MundialDB;User Id=login_app_abm;Password=<la-definida-localmente>;Encrypt=True;TrustServerCertificate=True"
```

Si en el entorno que se está empleando difiere algún dato, deben ajustarse los valores correspondientes. De manera genérica:

```text
Server=<HOST>;Database=MundialDB;User ID=<LOGIN>;Password=<CONTRASEÑA>;Encrypt=True;TrustServerCertificate=True
```

## 5. Compilación y ejecución

Desde una terminal ubicada en el directorio que contiene el archivo `.csproj`:

**Restaurar las dependencias:**

```powershell
dotnet restore
```

**Compilar el proyecto:**

```powershell
dotnet build
```

**Ejecutar la aplicación:**

```powershell
dotnet run
```

El comando `dotnet run` también restaura las dependencias y compila el proyecto cuando es necesario.

Una vez iniciada, la aplicación presenta un menú interactivo con las siguientes opciones:

| Opción | Operación |
|---|---|
| 1 | Alta de jugador |
| 2 | Modificación de jugador |
| 3 | Baja de jugador |
| 0 | Salir |

La ejecución requiere que SQL Server se encuentre disponible y que la identidad configurada tenga los permisos necesarios.

## 6. Consideraciones adicionales

- La variable `MUNDIAL_CS` se configura por sesión en el ejemplo de PowerShell. Al abrir una nueva terminal, debe volver a establecerse.
- Si se modifica o recrea `MundialDB`, deben verificarse nuevamente los procedimientos almacenados y los permisos del usuario de aplicación.
- La aplicación depende de los nombres, tipos y parámetros definidos en los procedimientos almacenados, así como de la estructura de los resultados devueltos por el procedimiento de consulta.
- La dependencia `Microsoft.Data.SqlClient` se administra desde el proyecto mediante NuGet. No requiere instalación independiente en el equipo del usuario.