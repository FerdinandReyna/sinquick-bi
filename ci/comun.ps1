# Funciones comunes de los scripts del pipeline
$ErrorActionPreference = 'Stop'
$Raiz = Split-Path -Parent $PSScriptRoot
Set-Location $Raiz

function Invocar {
    # Ejecuta un programa externo y detiene el pipeline si devuelve un código de error
    param([string]$Programa, [string[]]$Argumentos)
    Write-Host ">> $Programa $($Argumentos -join ' ')"
    & $Programa @Argumentos
    if ($LASTEXITCODE -ne 0) { throw "$Programa terminó con código $LASTEXITCODE" }
}

function Servidor { if ($env:SQL_SERVER) { $env:SQL_SERVER } else { 'localhost' } }
New-Item -ItemType Directory -Force -Path (Join-Path $Raiz 'reportes'), (Join-Path $Raiz 'artefactos') | Out-Null
