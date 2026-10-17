# Deploy (opcional): publica el informe en el área de trabajo de staging de Power BI.
# Requiere Power BI Pro, una entidad de servicio con acceso al área de trabajo y el
# módulo MicrosoftPowerBIMgmt. Las credenciales llegan desde Jenkins (withCredentials).
. "$PSScriptRoot\comun.ps1"
if (-not (Get-Module -ListAvailable MicrosoftPowerBIMgmt)) {
    Install-Module MicrosoftPowerBIMgmt -Scope CurrentUser -Force
}
$clave = ConvertTo-SecureString $env:PBI_SECRETO -AsPlainText -Force
$credencial = New-Object System.Management.Automation.PSCredential($env:PBI_CLIENTE, $clave)
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $credencial -Tenant $env:PBI_INQUILINO | Out-Null
New-PowerBIReport -Path 'powerbi\SINQuick.pbix' -WorkspaceId $env:PBI_AREA_STAGING -ConflictAction CreateOrOverwrite
Write-Host 'Informe publicado en el área de trabajo de staging'
