#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Build y run del entorno Docker para MetaCloudSim Paper 4.

.DESCRIPTION
    Construye la imagen Docker con Java 8 + Python 3.8 + jpy y lanza los
    servicios configurados en docker-compose.yml.

.EXAMPLE
    # Build inicial (solo primera vez)
    .\docker_build_and_run.ps1 -Action build

    # Smoke test
    .\docker_build_and_run.ps1 -Action smoke

    # Jupyter para analisis
    .\docker_build_and_run.ps1 -Action jupyter

    # Shell interactivo
    .\docker_build_and_run.ps1 -Action shell

    # Rebuild completo (si cambio Dockerfile)
    .\docker_build_and_run.ps1 -Action build -NoCache
#>

param(
    [ValidateSet("build", "smoke", "jupyter", "shell", "stop")]
    [string]$Action = "build",
    [switch]$NoCache
)

$ErrorActionPreference = "Stop"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PM = Split-Path -Parent $SCRIPT_DIR

Write-Host ""
Write-Host "=== Docker Build & Run: MetaCloudSim Paper 4 ===" -ForegroundColor Cyan
Write-Host "project_minimized: $PM"
Write-Host ""

# Verificar Docker
try { & docker --version | Out-Null }
catch {
    Write-Error "Docker no encontrado. Instalar desde: https://docs.docker.com/desktop/install/windows-install/"
    exit 1
}

Set-Location $PM

switch ($Action) {
    "build" {
        Write-Host "Construyendo imagen metacloudsim..." -ForegroundColor Yellow
        Write-Host "Esto puede tardar 5-15 minutos (compila jpy, instala dependencias Python)."
        Write-Host ""
        if ($NoCache) {
            & docker build --no-cache -t metacloudsim .
        } else {
            & docker build -t metacloudsim .
        }
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "Imagen construida exitosamente!" -ForegroundColor Green
            Write-Host "Siguiente paso: .\docker_build_and_run.ps1 -Action smoke"
        } else {
            Write-Error "Error al construir imagen"
        }
    }

    "smoke" {
        Write-Host "Ejecutando smoke test..." -ForegroundColor Green
        Write-Host "Config: paper4_smoke.json (tecnicas estaticas, no requiere pymodule)"
        Write-Host ""
        & docker-compose run --rm metacloudsim
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "Smoke test completado." -ForegroundColor Green
            Write-Host "Output en: results/smoke_test/"
        }
    }

    "jupyter" {
        Write-Host "Iniciando Jupyter Notebook..." -ForegroundColor Green
        Write-Host "Abrir en navegador: http://localhost:8888"
        Write-Host "Para detener: Ctrl+C o .\docker_build_and_run.ps1 -Action stop"
        Write-Host ""
        & docker-compose up jupyter
    }

    "shell" {
        Write-Host "Shell interactivo en container..." -ForegroundColor Yellow
        Write-Host "networkExperiments montado en /workspace/networkExperiments"
        Write-Host "Salir: exit"
        Write-Host ""
        & docker run -it --rm `
            -v "${PM}\..\networkExperiments:/workspace/networkExperiments" `
            -v "${PM}\results\smoke_test:/workspace/results/smoke_test" `
            -w /workspace/networkExperiments `
            metacloudsim bash
    }

    "stop" {
        Write-Host "Deteniendo servicios Docker..." -ForegroundColor Yellow
        & docker-compose down
        Write-Host "Servicios detenidos."
    }
}
