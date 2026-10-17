# Test: pruebas de integración, sistema, aceptación, seguridad y rendimiento con pytest.
# Con -Humo solo ejecuta las pruebas de solo lectura, para verificar un despliegue.
param(
    [Parameter(Mandatory)] [string]$Base,
    [switch]$Humo
)
. "$PSScriptRoot\comun.ps1"
$env:SQLSERVER_CONN = "DRIVER={ODBC Driver 18 for SQL Server};SERVER=$(Servidor);DATABASE=$Base;Trusted_Connection=yes;TrustServerCertificate=yes"
Invocar 'python' @('-m', 'pip', 'install', '-q', '-r', 'tests\pytest\requirements.txt')
$nombre  = if ($Humo) { 'pytest-staging' } else { 'pytest' }
$filtro  = if ($Humo) { 'humo' } else { 'not humo' }
Invocar 'python' @('-m', 'pytest', 'tests\pytest', '-m', $filtro, '-v',
                   "--html=reportes\$nombre.html", '--self-contained-html', "--junitxml=reportes\$nombre.xml")
