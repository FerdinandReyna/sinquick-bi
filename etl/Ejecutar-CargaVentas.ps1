# Alternativa al paquete SSIS para SQL Server Express (sin SSIS ni SQL Server Agent).
# Hace lo mismo que CargaVentas.dtsx: carga cada CSV de la carpeta de entrada con los
# mismos procedimientos y lo mueve a procesados o a errores. Se programa a las 23:00
# con el Programador de tareas de Windows.
param(
    [string]$CarpetaBase = 'C:\SINQuick\Produccion',
    [string]$Servidor    = 'localhost\SQLEXPRESS',
    [string]$Base        = 'SINQuick'
)
$ErrorActionPreference = 'Stop'
$entrada = Join-Path $CarpetaBase 'entrada'
$bitacora = Join-Path $CarpetaBase 'carga.log'
foreach ($archivo in Get-ChildItem (Join-Path $entrada '*.csv') | Sort-Object Name) {
    $ruta = $archivo.FullName
    $salida = & sqlcmd -S $Servidor -d $Base -E -C -b -h -1 -W -s '|' `
        -Q "SET NOCOUNT ON; EXEC etl.usp_EjecutarCargaVentas @ruta = N'$ruta', @tipoCarga = 'INCREMENTAL'"
    $destino = if ($LASTEXITCODE -eq 0) { 'procesados' } else { 'errores' }
    Move-Item $ruta (Join-Path (Join-Path $CarpetaBase $destino) $archivo.Name) -Force
    Add-Content $bitacora "$(Get-Date -Format s) $($archivo.Name) -> $destino | $($salida -join ' ')"
}
