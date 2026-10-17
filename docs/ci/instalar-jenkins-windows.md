# Preparar el agente de Jenkins en Windows

El pipeline corre en una PC con Windows 10/11 (puede ser tu propia computadora).
Se instala una sola vez.

## 1. Software

| Herramienta | Uso en el pipeline | Dónde se obtiene |
|---|---|---|
| SQL Server 2022 **Developer** con *Database Engine* e *Integration Services* | Bases CI y staging, catálogo SSISDB | Instalador de SQL Server → edición Developer |
| SQL Server Management Studio | Crear el catálogo SSISDB, revisar resultados | Microsoft |
| Visual Studio 2022 + extensión *SQL Server Integration Services Projects* | Crear el paquete SSIS | Visual Studio Installer / Marketplace |
| .NET SDK 8 | Compilar el proyecto de base de datos (DACPAC) | dot.net |
| SqlPackage | Publicar el DACPAC | `dotnet tool install -g microsoft.sqlpackage` |
| sqlcmd | Ejecutar scripts y tSQLt | Incluido con SQL Server / `winget install sqlcmd` |
| SSIS DevOps Tools (standalone) | `SSISBuild.exe` y `SSISDeploy.exe` | Descarga de Microsoft; descomprimir en `C:\Herramientas\SSISDevOps` |
| Python 3.12 | pytest | python.org (marcar *Add to PATH*) |
| ODBC Driver 18 for SQL Server | Conexión de pytest | Microsoft |
| Git | Checkout | git-scm.com |
| Jenkins LTS (instalador MSI) | Orquestar el pipeline | jenkins.io |

## 2. SQL Server

1. En SSMS: *Integration Services Catalogs* → clic derecho → **Create Catalog** (crea SSISDB).
2. La cuenta con que corre Jenkins necesita, en la instancia:
   - rol de servidor **dbcreator** (para recrear `SINQuick_CI`),
   - rol de servidor **bulkadmin** (BULK INSERT de los archivos),
   - rol **ssis_admin** en SSISDB (desplegar y ejecutar paquetes).
3. Crear las carpetas `C:\SINQuick\CI\entrada` y `C:\SINQuick\Staging\{entrada,procesados,errores}`
   y dar permiso de lectura a la cuenta del servicio de SQL Server.

## 3. Jenkins

1. Instalar Jenkins LTS. En *Service Logon* usar una cuenta de Windows con los permisos anteriores.
2. Plugins: **Pipeline**, **Git**, **JUnit**, **HTML Publisher**, **Workspace Cleanup**,
   **Timestamper**, **Pipeline: Stage View**.
3. *Manage Jenkins → Nodes → Built-In Node → Labels*: `windows-sql`.
4. *New Item* → **Multibranch Pipeline** → origen: tu repositorio de GitHub.
   Jenkins detecta el `Jenkinsfile` en cada rama.
5. Para que el reporte HTML se vea con estilos: *Manage Jenkins → Script Console* →
   `System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", "")` (solo en tu equipo de pruebas).

## 4. tSQLt

Descargar tSQLt y copiar `PrepareServer.sql` y `tSQLt.class.sql` en `tools\tSQLt\`.
