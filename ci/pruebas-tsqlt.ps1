# Test: pruebas unitarias con tSQLt y exportación de resultados en formato JUnit
param([Parameter(Mandatory)] [string]$Base)
. "$PSScriptRoot\comun.ps1"
$s = Servidor
foreach ($f in 'tools\tSQLt\PrepareServer.sql', 'tools\tSQLt\tSQLt.class.sql') {
    if (-not (Test-Path $f)) { throw "Falta $f. Descargue tSQLt de https://tsqlt.org y copie sus scripts en tools\tSQLt." }
}
Invocar 'sqlcmd' @('-S', $s, '-E', '-C', '-b', '-d', 'master', '-i', 'tools\tSQLt\PrepareServer.sql')
Invocar 'sqlcmd' @('-S', $s, '-E', '-C', '-b', '-d', $Base, '-i', 'tools\tSQLt\tSQLt.class.sql')
Get-ChildItem 'tests\tsqlt\*.sql' | Sort-Object Name | ForEach-Object {
    Invocar 'sqlcmd' @('-S', $s, '-E', '-C', '-b', '-d', $Base, '-i', $_.FullName)
}
# RunAll devuelve error si alguna prueba falla; primero se exportan los resultados
& sqlcmd -S $s -E -C -d $Base -Q "EXEC tSQLt.RunAll"
$fallo = $LASTEXITCODE
& sqlcmd -S $s -E -C -d $Base -h -1 -y 0 -Q "SET NOCOUNT ON; EXEC tSQLt.XmlResultFormatter" -o 'reportes\tsqlt.xml'
if ($fallo -ne 0) { throw 'Hay pruebas unitarias tSQLt fallidas' }
Write-Host 'Pruebas unitarias tSQLt aprobadas'
