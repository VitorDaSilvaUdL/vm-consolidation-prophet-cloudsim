#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Ejecuta el experimento completo del Paper 4 con WBF (fbProphet + autoARIMA + bollinger).

.DESCRIPTION
    REQUIERE: Java 8 + Python 3.8 + jpy compilado + pymodule de Sergi.

    Ejecuta los 4 workloads (planetlab, alibaba, materna, azure) con todas las
    tecnicas del paper para reproducir las Tablas 6-9.

    ADVERTENCIA: Cada workload puede tardar varias horas en la maquina original.

.EXAMPLE
    # Con Docker (cuando pymodule este disponible)
    .\run_paper4_full.ps1 -UseDocker -Workload planetlab

    # Con Java local + Python 3.8
    .\run_paper4_full.ps1 -Workload planetlab

    # Todos los workloads
    .\run_paper4_full.ps1 -AllWorkloads
#>

param(
    [switch]$UseDocker,
    [string]$JavaPath = "java",
    [ValidateSet("planetlab", "alibaba", "materna", "azure", "all")]
    [string]$Workload = "planetlab",
    [switch]$AllWorkloads
)

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PM = Split-Path -Parent $SCRIPT_DIR
$ROOT = Split-Path -Parent $PM
$NE = Join-Path $ROOT "networkExperiments"

Write-Host ""
Write-Host "=== Paper 4 Experimento Completo WBF ===" -ForegroundColor Cyan
Write-Host "ADVERTENCIA: Requiere jpy compilado + pymodule de Sergi" -ForegroundColor Yellow
Write-Host ""

# Verificar pymodule
$launcher = Join-Path $NE "launcher.json"
if (Test-Path $launcher) {
    $launcherJson = Get-Content $launcher | ConvertFrom-Json
    $pymodulePath = $launcherJson.pymodule
    if (-not (Test-Path $pymodulePath)) {
        Write-Host "ERROR CRITICO: pymodule no encontrado en: $pymodulePath" -ForegroundColor Red
        Write-Host ""
        Write-Host "El codigo Python de CloudSim (fbProphet, autoARIMA, knn, etc.) no esta en el repo." -ForegroundColor Yellow
        Write-Host "Pasos para obtenerlo:" -ForegroundColor Yellow
        Write-Host "  1. Contactar a Sergi Vila: sergi.vila@inspires.udl.cat"
        Write-Host "  2. Pedir el directorio: workspaceCloud2019/cloudsim_base/cloudsim/src/main/python"
        Write-Host "  3. Colocarlo en networkExperiments/ o ajustar launcher.json"
        Write-Host ""
        Write-Host "Alternativa: ejecutar smoke test sin jpy: .\run_smoke_test.ps1"
        exit 1
    }
} else {
    Write-Warning "launcher.json no encontrado. Copia configs/launcher.example.json a networkExperiments/launcher.json"
}

# Configurar workloads a ejecutar
if ($AllWorkloads) { $Workload = "all" }
$workloads = switch ($Workload) {
    "all"      { @("planetlab", "alibaba", "materna", "azure") }
    default    { @($Workload) }
}

# Mapeo workload -> config JSON del paper
$workloadConfigs = @{
    "planetlab" = "paper4_test3_planetlab_10traces_30_wbf"
    "alibaba"   = "paper4_test3_alibaba_30_wbf"
    "materna"   = "paper4_test3_materna_30_wbf"
    "azure"     = "paper4_test3_azure_30_wbf"
}

foreach ($wl in $workloads) {
    $configName = $workloadConfigs[$wl]
    Write-Host ""
    Write-Host "--- Workload: $wl (config: $configName) ---" -ForegroundColor Cyan

    if ($UseDocker) {
        Set-Location $PM
        # Modificar temporalmente docker-compose para usar esta config
        Write-Host "Ejecutando via Docker..." -ForegroundColor Yellow
        & docker-compose run --rm metacloudsim java -jar netcloud.jar testbed $configName
    } else {
        Push-Location $NE
        try {
            Write-Host "Ejecutando: java -jar netcloud.jar testbed $configName" -ForegroundColor Green
            $startTime = Get-Date
            & $JavaPath -jar netcloud.jar testbed $configName
            $elapsed = (Get-Date) - $startTime
            Write-Host "Completado en $($elapsed.TotalMinutes.ToString('F1')) minutos" -ForegroundColor Green
        } catch {
            Write-Host "Error en workload $wl: $_" -ForegroundColor Red
        } finally {
            Pop-Location
        }
    }
}

Write-Host ""
Write-Host "=== Experimento completo finalizado ===" -ForegroundColor Cyan
Write-Host "Resultados en: $NE\generatedExperiments\"
Write-Host ""
Write-Host "Para analizar resultados:"
Write-Host "  1. Abrir python/notebooks/statistics_paper4.ipynb"
Write-Host "  2. Ajustar baseFolder a networkExperiments/generatedExperiments/"
Write-Host "  3. Ejecutar todas las celdas"
Write-Host "  O: jupyter nbconvert --to notebook --execute python/notebooks/statistics_paper4.ipynb"
