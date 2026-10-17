# Build: compila el proyecto de base de datos y produce el DACPAC
. "$PSScriptRoot\comun.ps1"
Invocar 'dotnet' @('build', 'database\SINQuick.DB\SINQuick.DB.sqlproj', '-c', 'Release', '-nologo')
New-Item -ItemType Directory -Force -Path 'artefactos\db' | Out-Null
Copy-Item 'database\SINQuick.DB\bin\Release\SINQuick.DB.dacpac' 'artefactos\db\' -Force
Write-Host "DACPAC generado: artefactos\db\SINQuick.DB.dacpac"
