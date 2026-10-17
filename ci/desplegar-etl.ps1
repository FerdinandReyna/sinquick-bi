# Deploy: publica el paquete SSIS en el catálogo SSISDB y lo ejecuta una vez como verificación
param(
    [Parameter(Mandatory)] [string]$Carpeta,   # carpeta del catálogo SSISDB, por ejemplo: Staging
    [Parameter(Mandatory)] [string]$Base       # base de datos a la que apunta el paquete
)
. "$PSScriptRoot\comun.ps1"
$s = Servidor
$carpetaCatalogo = "SINQuick_$Carpeta"   # una carpeta del catálogo por entorno
Invocar 'sqlcmd' @('-S', $s, '-E', '-C', '-b', '-d', 'SSISDB', '-Q',
    "IF NOT EXISTS (SELECT 1 FROM catalog.folders WHERE name = N'$carpetaCatalogo') EXEC catalog.create_folder @folder_name = N'$carpetaCatalogo';")
$ssisDeploy = Join-Path $env:SSIS_DEVOPS 'SSISDeploy.exe'
Invocar $ssisDeploy @('-source:artefactos\etl\SINQuick.ETL.ispac', "-destination:catalog;/SSISDB/$carpetaCatalogo;$s", '-authtype:WIN')

# Datos de referencia del entorno (catálogo de productos y asesores exportado del punto de venta)
Invocar 'sqlcmd' @('-S', $s, '-E', '-C', '-b', '-d', $Base, '-i', 'database\datos-referencia\catalogo_inicial.sql')

# Ejecución de verificación con un archivo de muestra (síncrona: espera a que termine)
$entrada = "C:\SINQuick\$Carpeta\entrada"
New-Item -ItemType Directory -Force -Path $entrada, "C:\SINQuick\$Carpeta\procesados", "C:\SINQuick\$Carpeta\errores" | Out-Null
Copy-Item 'tests\datos\muestra_staging.csv' (Join-Path $entrada "muestra_$(Get-Date -Format yyyyMMddHHmmss).csv")
$sql = @"
DECLARE @id BIGINT;
EXEC catalog.create_execution @folder_name = N'$carpetaCatalogo', @project_name = N'SINQuick.ETL', @package_name = N'CargaVentas.dtsx', @execution_id = @id OUTPUT;
EXEC catalog.set_execution_parameter_value @id, @object_type = 30, @parameter_name = N'CarpetaBase', @parameter_value = N'C:\SINQuick\$Carpeta';
EXEC catalog.set_execution_parameter_value @id, @object_type = 20, @parameter_name = N'CM.SINQuick.ServerName', @parameter_value = N'$s';
EXEC catalog.set_execution_parameter_value @id, @object_type = 20, @parameter_name = N'CM.SINQuick.InitialCatalog', @parameter_value = N'$Base';
EXEC catalog.set_execution_parameter_value @id, @object_type = 50, @parameter_name = N'SYNCHRONIZED', @parameter_value = 1;
EXEC catalog.start_execution @id;
IF (SELECT status FROM catalog.executions WHERE execution_id = @id) <> 7
    THROW 50100, N'El paquete CargaVentas.dtsx no terminó correctamente en staging.', 1;
"@
Invocar 'sqlcmd' @('-S', $s, '-E', '-C', '-b', '-d', 'SSISDB', '-Q', $sql)
Write-Host "Paquete desplegado y verificado en /SSISDB/$carpetaCatalogo"
