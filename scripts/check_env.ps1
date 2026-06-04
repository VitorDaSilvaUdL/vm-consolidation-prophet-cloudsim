#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Verifica el entorno necesario para ejecutar Paper 4 MetaCloudSim.

.DESCRIPTION
    Comprueba Java 8, Python 3.8, jpy, prophet, y pymodule.
    Indica el estado de cada componente y que hacer para resolverlo.

.EXAMPLE
    .\check_env.ps1
    .\check_env.ps1 -Verbose
#>

param(
    [string]$JavaPath = "java",
    [string]$PythonPath = "python",
    [switch]$Verbose
)

$ErrorActionPreference = "SilentlyContinue"

$BASE = "C:\Users\PcVIP\Desktop\Proyecto Sergi"
$NE = Join-Path $BASE "networkExperiments"
$PM = Join-Path $BASE "project_minimized"

$ok = [char]0x2705    # checkmark verde (texto fallback: OK)
$fail = [char]0x274C  # X roja (texto fallback: FAIL)
$warn = [char]0x26A0  # advertencia (texto fallback: WARN)

function Check-Status {
    param([bool]$Ok, [string]$Label, [string]$Detail, [string]$Fix)
    if ($Ok) {
        Write-Host "  $ok  $Label" -ForegroundColor Green
        if ($Verbose -and $Detail) { Write-Host "       $Detail" -ForegroundColor DarkGray }
    } else {
        Write-Host "  $fail  $Label" -ForegroundColor Red
        Write-Host "       FIX: $Fix" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Verificacion de entorno: Paper 4 MetaCloudSim ===" -ForegroundColor Cyan
Write-Host "Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor DarkGray
Write-Host ""

# 1. Java
Write-Host "[1/6] Java JDK 8" -ForegroundColor White
$javaVersion = ""
try {
    $javaOut = & $JavaPath -version 2>&1
    $javaVersion = $javaOut | Select-Object -First 1
    $isJava8 = $javaVersion -match "1\.8\." -or $javaVersion -match "version.*8"
    Check-Status -Ok $isJava8 -Label "Java 8 encontrado: $javaVersion" -Detail $javaVersion `
        -Fix "Instalar JDK 8 desde https://adoptium.net/temurin/releases/?version=8 o usar Docker"
} catch {
    Check-Status -Ok $false -Label "Java no encontrado" `
        -Fix "Instalar JDK 8 desde https://adoptium.net/temurin/releases/?version=8 o usar Docker"
}

# 2. Python 3.8
Write-Host ""
Write-Host "[2/6] Python 3.8" -ForegroundColor White
$pythonVersion = ""
try {
    $pyOut = & $PythonPath --version 2>&1
    $pythonVersion = $pyOut.ToString()
    $isPy38 = $pythonVersion -match "Python 3\.8\."
    Check-Status -Ok $isPy38 -Label "Python 3.8: $pythonVersion" -Detail $pythonVersion `
        -Fix "Instalar Python 3.8: pyenv install 3.8.18  O usar Docker"
} catch {
    Check-Status -Ok $false -Label "Python no encontrado" `
        -Fix "Instalar Python 3.8 desde https://www.python.org/downloads/release/python-3818/"
}

# 3. prophet
Write-Host ""
Write-Host "[3/6] Prophet (forecasting)" -ForegroundColor White
try {
    $prophetOut = & $PythonPath -c "import prophet; print(prophet.__version__)" 2>&1
    $hasProphet = $LASTEXITCODE -eq 0
    Check-Status -Ok $hasProphet -Label "prophet: $prophetOut" -Detail $prophetOut `
        -Fix "pip install prophet==1.1.1  (requiere Python 3.8)"
} catch {
    Check-Status -Ok $false -Label "prophet NO instalado" `
        -Fix "pip install prophet==1.1.1  (requiere Python 3.8)"
}

# 4. jpy
Write-Host ""
Write-Host "[4/6] jpy (bridge Java-Python)" -ForegroundColor White
$launcher = Join-Path $NE "launcher.json"
$jpyFound = $false
if (Test-Path $launcher) {
    try {
        $launcherJson = Get-Content $launcher | ConvertFrom-Json
        $jpyPath = $launcherJson.jpyLib
        if ($jpyPath -and (Test-Path $jpyPath)) {
            $jpyFound = $true
            Check-Status -Ok $true -Label "jpy encontrado: $jpyPath" -Detail $jpyPath `
                -Fix "N/A"
        } else {
            Check-Status -Ok $false -Label "jpyLib en launcher.json no existe: $jpyPath" `
                -Fix "Compilar jpy: git clone https://github.com/jpy-consortium/jpy && python setup.py build maven  O usar Docker"
        }
    } catch {
        Check-Status -Ok $false -Label "launcher.json no parseable" `
            -Fix "Verificar $launcher"
    }
} else {
    Check-Status -Ok $false -Label "launcher.json no encontrado en $NE" `
        -Fix "Copiar configs/launcher.example.json a networkExperiments/launcher.json y ajustar paths"
}

# 5. pymodule
Write-Host ""
Write-Host "[5/6] pymodule (codigo Python CloudSim)" -ForegroundColor White
$pymodulePath = ""
if (Test-Path $launcher) {
    try {
        $launcherJson = Get-Content $launcher | ConvertFrom-Json
        $pymodulePath = $launcherJson.pymodule
        if ($pymodulePath -and (Test-Path $pymodulePath)) {
            # Verificar que tenga archivos Python
            $pyFiles = Get-ChildItem $pymodulePath -Filter "*.py" -ErrorAction SilentlyContinue
            $hasPymodule = $pyFiles.Count -gt 0
            Check-Status -Ok $hasPymodule -Label "pymodule encontrado ($($pyFiles.Count) archivos .py): $pymodulePath" `
                -Fix "N/A"
        } else {
            Check-Status -Ok $false -Label "pymodule NO encontrado: $pymodulePath" `
                -Fix "CRITICO: Pedir a Sergi el directorio workspaceCloud2019/cloudsim_base/cloudsim/src/main/python"
        }
    } catch {}
} else {
    Check-Status -Ok $false -Label "pymodule: no verificable (launcher.json no encontrado)" `
        -Fix "CRITICO: Pedir a Sergi el directorio cloudsim/src/main/python"
}

# 6. Docker
Write-Host ""
Write-Host "[6/6] Docker (alternativa)" -ForegroundColor White
try {
    $dockerOut = & docker --version 2>&1
    $hasDocker = $LASTEXITCODE -eq 0
    Check-Status -Ok $hasDocker -Label "Docker disponible: $dockerOut" -Detail $dockerOut `
        -Fix "Instalar Docker Desktop: https://docs.docker.com/desktop/install/windows-install/"
} catch {
    Check-Status -Ok $false -Label "Docker NO encontrado" `
        -Fix "Instalar Docker Desktop: https://docs.docker.com/desktop/install/windows-install/"
}

# Resumen
Write-Host ""
Write-Host "=== Resumen ===" -ForegroundColor Cyan
Write-Host "Para smoke test (tecnicas estaticas, sin jpy):"
Write-Host "  - Si Docker disponible: .\run_smoke_test.ps1 -UseDocker"
Write-Host "  - Si Java 8 disponible: .\run_smoke_test.ps1"
Write-Host ""
Write-Host "Para experimento completo WBF (con Prophet/NeuralProphet):"
Write-Host "  Requiere: Java 8 + Python 3.8 + jpy compilado + pymodule de Sergi"
Write-Host ""
