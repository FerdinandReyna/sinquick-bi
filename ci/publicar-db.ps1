# Publica el DACPAC en una base de datos (CI o staging)
param(
    [Parameter(Mandatory)] [string]$Base,
    [switch]$Recrear   # solo para la base de CI: se crea desde cero en cada ejecución
)
. "$PSScriptRoot\comun.ps1"
$argumentos = @(
    '/Action:Publish',
    '/SourceFile:artefactos\db\SINQuick.DB.dacpac',
    "/TargetServerName:$(Servidor)",
    "/TargetDatabaseName:$Base",
    '/TargetTrustServerCertificate:True',
    '/p:BlockOnPossibleDataLoss=True',
    "/p:CreateNewDatabase=$($Recrear.IsPresent)"
)
Invocar 'sqlpackage' $argumentos
Write-Host "Base $Base publicada en $(Servidor)"
