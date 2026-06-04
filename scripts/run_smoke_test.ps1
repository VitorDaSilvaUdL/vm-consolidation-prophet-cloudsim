#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Ejecuta el smoke test del Paper 4 usando tecnicas estaticas (sin jpy).

.DESCRIPTION
    Ejecuta el simulador MetaCloudSim (netcloud.jar) con la configuracion minima
    paper4_smoke.json que usa solo la tecnica "last" (estatica, sin Python bridge).

    Opciones:
    -UseDocker: Usa Docker (recomendado si no hay Java 8 local)
    -JavaPath:  Ruta al ejecutable java (default: "java")
    -CopyConfig: Copia paper4_smoke.json al directorio testbed antes de ejecutar

.EXAMPLE
    # Con Docker (no requiere Java local)
    .\run_smoke_test.ps1 -UseDocker

    # Con Java local
    .\run_smoke_test.ps1

    # Con Java en ruta especifica
    .\run_smoke_test.ps1 -JavaPath "C:\Program Files\Eclipse Adoptium\jdk-8.x\bin\java.exe"
#>

param(
    [switch]$UseDocker,
    [string]$JavaPath = "java",
    [switch]$CopyConfig
)

$ErrorActionPreference = "Stop"

# Paths
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PM = Split-Path -Parent $SCRIPT_DIR
$ROOT = Split-Path -Parent $PM
$NE = Join-Path $ROOT "networkExperiments"
$SMOKE_CONFIG = Join-Path $PM "configs\paper4\paper4_smoke.json"
$SMOKE_OUTPUT = Join-Path $PM "results\smoke_test"

Write-Host ""
Write-Host "=== Paper 4 Smoke Test ===" -ForegroundColor Cyan
Write-Host "networkExperiments: $NE"
Write-Host "Config: $SMOKE_CONFIG"
Write-Host "Output: $SMOKE_OUTPUT"
Write-Host ""

# Verificar que networkExperiments/ existe
if (-not (Test-Path $NE)) {
    Write-Error "networkExperiments/ no encontrado en: $NE"
    exit 1
}

# Verificar que netcloud.jar existe
$JAR = Join-Path $NE "netcloud.jar"
if (-not (Test-Path $JAR)) {
    Write-Error "netcloud.jar no encontrado en: $JAR"
    exit 1
}

# Copiar config smoke test si se solicita o si no existe en testbed/
$TESTBED_SMOKE = Join-Path $NE "testbed\paper4_smoke.json"
if ($CopyConfig -or -not (Test-Path $TESTBED_SMOKE)) {
    Write-Host "Copiando paper4_smoke.json a testbed/..." -ForegroundColor Yellow
    Copy-Item $SMOKE_CONFIG $TESTBED_SMOKE -Force
    Write-Host "Copiado: $TESTBED_SMOKE"
}

if ($UseDocker) {
    Write-Host "Modo: Docker" -ForegroundColor Yellow

    # Verificar Docker
    try { & docker --version | Out-Null } catch {
        Write-Error "Docker no encontrado. Instalar desde: https://docs.docker.com/desktop/install/windows-install/"
        exit 1
    }

    # Build si no existe la imagen
    $imgExists = docker images -q metacloudsim 2>&1
    if (-not $imgExists) {
        Write-Host "Construyendo imagen Docker (primera vez, ~5-10 min)..." -ForegroundColor Yellow
        Set-Location $PM
        & docker build -t metacloudsim .
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Error al construir imagen Docker"
            exit 1
        }
    }

    # Ejecutar smoke test via docker-compose
    Set-Location $PM
    Write-Host "Ejecutando smoke test en Docker..." -ForegroundColor Green
    & docker-compose run --rm metacloudsim
    $exitCode = $LASTEXITCODE

} else {
    Write-Host "Modo: Java local" -ForegroundColor Yellow

    # Verificar Java
    try {
        $jv = & $JavaPath -version 2>&1 | Select-Object -First 1
        Write-Host "Java: $jv"
        if ($jv -notmatch "1\.8\." -and $jv -notmatch "version.*8") {
            Write-Warning "ADVERTENCIA: Se detecto Java version $jv. Se necesita Java 8."
            Write-Warning "Continuar de todas formas? (puede fallar con Java 11+)"
        }
    } catch {
        Write-Error "Java no encontrado en '$JavaPath'. Instala JDK 8 o usa -UseDocker"
        exit 1
    }

    # Ejecutar simulacion
    Write-Host "Ejecutando simulacion..." -ForegroundColor Green
    $startTime = Get-Date

    Push-Location $NE
    try {
        & $JavaPath -jar netcloud.jar testbed paper4_smoke
        $exitCode = $LASTEXITCODE
    } finally {
        Pop-Location
    }

    $elapsed = (Get-Date) - $startTime
    Write-Host "Tiempo: $($elapsed.TotalSeconds.ToString('F1'))s"
}

# Verificar resultado
Write-Host ""
if ($exitCode -eq 0) {
    # Buscar output generado
    $outputDir = Join-Path $NE "generatedExperiments\paper4_smoke"
    if (-not (Test-Path $outputDir)) {
        $outputDir = $SMOKE_OUTPUT
    }

    if (Test-Path $outputDir) {
        $jsonFiles = Get-ChildItem $outputDir -Filter "*_data.json" -Recurse -ErrorAction SilentlyContinue
        $allFiles = Get-ChildItem $outputDir -Recurse -ErrorAction SilentlyContinue
        Write-Host "SMOKE TEST OK" -ForegroundColor Green
        Write-Host "Output en: $outputDir"
        Write-Host "Ficheros JSON generados: $($jsonFiles.Count)"
        Write-Host "Ficheros totales: $($allFiles.Count)"
    } else {
        Write-Warning "Simulacion termino (exit 0) pero no se encontro output en $outputDir"
    }
} else {
    Write-Host "SMOKE TEST FALLO (exit code: $exitCode)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Posibles causas:" -ForegroundColor Yellow
    Write-Host "  1. Java version incorrecta (necesita Java 8)"
    Write-Host "  2. launcher.json con paths incorrectos"
    Write-Host "  3. workload planetlab_100_mostDiff no encontrado en workloads/"
    Write-Host "  4. topologia fatTreeTopology_k-2 no encontrada en topologies/"
    Write-Host ""
    Write-Host "Ver logs en: $NE\generatedExperiments\paper4_smoke\outputLog\"
    exit 1
}
