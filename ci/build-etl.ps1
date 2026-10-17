# Build: compila el proyecto SSIS y produce el archivo .ispac
. "$PSScriptRoot\comun.ps1"
$proyecto = 'etl\SINQuick.ETL\SINQuick.ETL.dtproj'
if (-not (Test-Path $proyecto)) {
    throw "No se encontró $proyecto. Cree el proyecto SSIS en Visual Studio siguiendo etl\README.md."
}
$ssisBuild = Join-Path $env:SSIS_DEVOPS 'SSISBuild.exe'
Invocar $ssisBuild @("-project:$proyecto", '-configuration:Development', '-output:artefactos\etl')
Write-Host "Paquete SSIS generado en artefactos\etl"
