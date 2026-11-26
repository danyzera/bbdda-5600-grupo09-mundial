@echo off
rem ============================================================================
rem  Universidad : Universidad Nacional de La Matanza (UNLaM)
rem  Materia     : 3641 - Bases de Datos Aplicada
rem  Comision    : Com:5600      Grupo:09
rem  Integrantes : Gauto, Andino, Garbaccio, Dugo
rem  Script      : reconstruir_bd.bat   (ubicar en sql/, junto a las carpetas 01..08)
rem  Descripcion : Puramente una herramienta de desarrollo para facilitar la reconstruccion de la base MundialDB
rem  Objetivo    : Elimina y recrea MundialDB ejecutando, en el orden numerico de
rem                los scripts: estructura (00-01), funciones/vistas (02-03), ABM
rem                (04-12), logica de negocio (13-21), importadores (22-27),
rem                reportes (28-34), seguridad (35-37) y seed (38).
rem                No ejecuta tests (sql\tests). Es una herramienta de desarrollo.
rem  Uso         : reconstruir_bd.bat [/y]   (/y: sin confirmacion y sin pausa final)
rem  Config      : set SQL_SERVER=.\SQLEXPRESS   (por defecto: localhost)
rem                set SQL_TRUST_CERT=1          (si falla por certificado TLS)
rem  Requisitos  : sqlcmd en el PATH, login de Windows con rol sysadmin y SQL
rem                Server en la misma maquina (BULK INSERT lee desde el servidor).
rem  Nota        : Dado que el proyecto es esencialmente SQL, se comento el codigo de este .bat para que sea facil de leer y entender.
rem                Verificar que el formateo que se le dio al .bat sea CRLF (Windows) y no LF (Linux) para que funcione correctamente.
rem ============================================================================

setlocal EnableExtensions
chcp 65001 >nul

set "CODIGO_RETORNO=0"
set "MODO_AUTOMATICO=0"
if /i "%~1"=="/y" set "MODO_AUTOMATICO=1"

if not defined SQL_SERVER set "SQL_SERVER=localhost"
set "CARPETA_SQL=%~dp0"
set "CARPETA_DATOS=C:\Temp"
set "CARPETA_CSV=%CARPETA_SQL%datasets"

rem Una suerte de define para un conjunto de opciones de sqlcmd que se repiten en cada invocacion. Facilita el hecho de no tener que repetirlas.
rem   -S servidor            a que instancia de SQL Server conectarse
rem   -E                     usar la sesion de Windows
rem   -b                     si un script falla, cortar y devolver error
rem   -I                     activar QUOTED_IDENTIFIER
rem   -f 65001               leer los archivos .sql como UTF-8 (tildes y enies)
set "SQLCMD=sqlcmd -S %SQL_SERVER% -E -b -I -f 65001"
if defined SQL_TRUST_CERT set "SQLCMD=%SQLCMD% -C"

where sqlcmd >nul 2>&1
if errorlevel 1 (
    echo ERROR: no se encuentra sqlcmd en el PATH.
    goto :error
)

rem --- Paso previo: verificar que existan todos los archivos antes de borrar nada ---
rem FALTAN se usa como bool: si queda true, falta al menos un archivo.
set "MODO=SOLO_VERIFICAR_EXISTENCIA"
set "FALTAN="
rem Primero se controlan los dos CSV que se van a copiar mas abajo.
if not exist "%CARPETA_CSV%\referees.csv" (
    echo ERROR: no existe "%CARPETA_CSV%\referees.csv"
    set "FALTAN=1"
)
if not exist "%CARPETA_CSV%\sedes_wikipedia.csv" (
    echo ERROR: no existe "%CARPETA_CSV%\sedes_wikipedia.csv"
    set "FALTAN=1"
)
rem Luego se recorre la lista de scripts, pero sin ejecutar nada, por lo que define la variable MODO
call :secuencia
if defined FALTAN (
    echo Faltan archivos: revisar nombres y numeracion antes de reconstruir.
    goto :error
)

if "%MODO_AUTOMATICO%"=="1" goto :confirmado
echo Esto ELIMINA la base MundialDB en %SQL_SERVER% y la vuelve a crear.
choice /c SN /m "Continuar"
if errorlevel 2 goto :fin
:confirmado

if not exist "%CARPETA_DATOS%" mkdir "%CARPETA_DATOS%"
copy /y "%CARPETA_CSV%\referees.csv" "%CARPETA_DATOS%\" >nul || goto :error
copy /y "%CARPETA_CSV%\sedes_wikipedia.csv" "%CARPETA_DATOS%\" >nul || goto :error

rem A partir de ahora se hara efectivamente el sqlcmd para el script correspondiente; no solo se verifica si existen los scripts o no
set "MODO=EJECUTAR"
call :secuencia || goto :error

echo.
echo === MundialDB reconstruida correctamente ===
goto :fin

:secuencia

call :ejecutar "01_estructura\00_crear_bd_y_esquemas.sql" master || exit /b 1
call :ejecutar "01_estructura\01_crear_tablas.sql" MundialDB || exit /b 1

call :ejecutar "02_funciones_vistas\02_crear_funciones_reutilizables.sql" MundialDB || exit /b 1
call :ejecutar "02_funciones_vistas\03_crear_vistas.sql" MundialDB || exit /b 1

call :ejecutar "03_abm\04_sp_alta_torneo.sql" MundialDB || exit /b 1
call :ejecutar "03_abm\05_sp_alta_arbitraje.sql" MundialDB || exit /b 1
call :ejecutar "03_abm\06_sp_alta_publicidad.sql" MundialDB || exit /b 1
call :ejecutar "03_abm\07_sp_baja_torneo.sql" MundialDB || exit /b 1
call :ejecutar "03_abm\08_sp_baja_arbitraje.sql" MundialDB || exit /b 1
call :ejecutar "03_abm\09_sp_baja_publicidad.sql" MundialDB || exit /b 1
call :ejecutar "03_abm\10_sp_modificacion_torneo.sql" MundialDB || exit /b 1
call :ejecutar "03_abm\11_sp_modificacion_arbitraje.sql" MundialDB || exit /b 1
call :ejecutar "03_abm\12_sp_modificacion_publicidad.sql" MundialDB || exit /b 1

call :ejecutar "04_logica-negocio\13_sp_partido_iniciar.sql" MundialDB || exit /b 1
call :ejecutar "04_logica-negocio\14_sp_gol_registrar.sql" MundialDB || exit /b 1
call :ejecutar "04_logica-negocio\15_sp_tarjeta_registrar.sql" MundialDB || exit /b 1
call :ejecutar "04_logica-negocio\16_sp_cambio_registrar.sql" MundialDB || exit /b 1
call :ejecutar "04_logica-negocio\17_sp_partido_finalizar.sql" MundialDB || exit /b 1
call :ejecutar "04_logica-negocio\18_sp_convocatoria_reemplazar.sql" MundialDB || exit /b 1
call :ejecutar "04_logica-negocio\19_sp_terna_arbitral_designar.sql" MundialDB || exit /b 1
call :ejecutar "04_logica-negocio\20_sp_publicidad_partido_asignar.sql" MundialDB || exit /b 1
call :ejecutar "04_logica-negocio\21_sp_alineacion_cargar.sql" MundialDB || exit /b 1

call :ejecutar "05_importacion\22_sp_importar_paises_csv.sql" MundialDB || exit /b 1
call :ejecutar "05_importacion\23_sp_importar_fixture_csv.sql" MundialDB || exit /b 1
call :ejecutar "05_importacion\24_sp_importar_plantillas_csv.sql" MundialDB || exit /b 1
call :ejecutar "05_importacion\25_sp_importar_arbitros_xml.sql" MundialDB || exit /b 1
call :ejecutar "05_importacion\26_sp_importar_sedes_wikipedia.sql" MundialDB || exit /b 1
call :ejecutar "05_importacion\27_sp_importar_arbitros.sql" MundialDB || exit /b 1

call :ejecutar "06_reportes\28_sp_goleadores.sql" MundialDB || exit /b 1
call :ejecutar "06_reportes\29_sp_tarjetas_suspensiones.sql" MundialDB || exit /b 1
call :ejecutar "06_reportes\30_sp_designaciones_arbitrales.sql" MundialDB || exit /b 1
call :ejecutar "06_reportes\31_sp_publicidad_sede.sql" MundialDB || exit /b 1
call :ejecutar "06_reportes\32_sp_matriz_primetime.sql" MundialDB || exit /b 1
call :ejecutar "06_reportes\33_sp_selecciones_plantilla_xml.sql" MundialDB || exit /b 1
call :ejecutar "06_reportes\34_sp_resultados_xml.sql" MundialDB || exit /b 1

call :ejecutar "07_seguridad\35_seguridad_cifrado.sql" MundialDB || exit /b 1
call :ejecutar "07_seguridad\36_seguridad_roles.sql" MundialDB || exit /b 1
call :ejecutar "07_seguridad\37_seguridad_usuarios.sql" MundialDB || exit /b 1

call :ejecutar "08_seed\38_seed_final.sql" MundialDB || exit /b 1

exit /b 0

:ejecutar
set "ARCHIVO=%CARPETA_SQL%%~1"
if not exist "%ARCHIVO%" (
    echo ERROR: no existe "%ARCHIVO%"
    if "%MODO%"=="SOLO_VERIFICAR_EXISTENCIA" set "FALTAN=1"
    if "%MODO%"=="SOLO_VERIFICAR_EXISTENCIA" exit /b 0
    exit /b 1
)

if "%MODO%"=="SOLO_VERIFICAR_EXISTENCIA" exit /b 0
echo ^>^> %~1
%SQLCMD% -d %~2 -i "%ARCHIVO%"
if errorlevel 1 (
    echo ERROR: fallo la ejecucion de %~1
    exit /b 1
)
exit /b 0

:error
set "CODIGO_RETORNO=1"
echo.
echo === Reconstruccion ABORTADA ===

:fin
if "%MODO_AUTOMATICO%"=="0" pause
exit /b %CODIGO_RETORNO%