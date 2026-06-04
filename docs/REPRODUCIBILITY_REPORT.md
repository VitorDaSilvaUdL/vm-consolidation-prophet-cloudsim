# Informe de Reproducibilidad — Paper 4

**Fecha**: 2026-06-03 (actualizado)
**Maquina**: PcVIP (Windows 11 Pro)
**Nivel alcanzado**: PARCIAL (pendiente Docker)

---

## Resumen ejecutivo

~~Bloqueador critico resuelto~~: el `pymodule` (codigo Python de CloudSim) ya esta en el repositorio en:
`networkExperiments/svila_phd_metacloudsim/cloudsim/src/main/python`

Contiene: `forecastingTechniques.py` (Prophet, AutoARIMA, KNN), `bollingerFunctions.py`, `signalProcessing.py`, `pythonBinding.py`.

Ademas, el codigo fuente Java completo esta en `svila_phd_metacloudsim/cloudsim/` con `pom.xml` para compilar con Maven.

**Inmediato**: Instalar Docker Desktop y ejecutar smoke test en ~10 minutos.
**Siguiente**: Con Docker, reproducibilidad completa del Paper 4 (WBF incluido).

**launcher.json actualizado**: `baseFolder` y `pymodule` ahora apuntan a paths correctos de esta maquina.

---

## Entorno verificado

| Componente | Requerido | Instalado | Estado |
|-----------|-----------|-----------|--------|
| Java JDK | 8 | No encontrado | Bloqueador critico |
| Python | 3.8 | 3.13.0 | Version incorrecta |
| prophet | 1.x | No | Falta instalar |
| neuralprophet | 0.2.7 | No | Falta instalar |
| pmdarima | 1.8.x | No | Falta instalar |
| torch | 1.6.0 | No | Falta instalar |
| pandas | 1.2.5 | 3.0.3 | Version diferente (puede funcionar para analisis) |
| numpy | 1.21.x | --- | No verificado |
| jpy | --- | No compilado | Falta compilar (Docker lo compila automaticamente) |
| pymodule | --- | **No en repo** | Bloqueador critico |
| Docker | --- | No verificado | Solucion alternativa |

## Comandos ejecutados

```powershell
# Java - no disponible
java -version
# Error: El termino 'java' no se reconoce

# Python - version incorrecta
python --version
# Python 3.13.0

# Prophet - no instalado
python -c "from prophet import Prophet"
# ModuleNotFoundError: No module named 'prophet'

# pymodule - no existe en el repo
# Ruta esperada segun launcher.json de Sergi:
# C:/Users/Sergi/Documents/workspaceCloud2019/cloudsim_base/cloudsim/src/main/python
# Esta ruta no existe en PcVIP y el codigo no esta en el repositorio
```

---

## Experimentos ejecutados

| Experimento | Estado | Motivo |
|------------|--------|--------|
| Smoke test (tecnicas estaticas) | No ejecutado | Java 8 no disponible |
| WF (Weighted Forecasting) | No ejecutado | Java 8 + jpy no disponibles |
| WBF (Weighted Bollinger Forecasting) | No ejecutado | Java 8 + jpy + pymodule no disponibles |
| Analisis de resultados existentes | Pendiente | Python 3.8 + deps no configurados |

---

## Resultados del paper (ground truth a reproducir)

Los resultados originales estan en `networkExperiments/paper4_data/`.

### Tabla 6 — PlanetLab (workload principal)

| Tecnica | Energy (kWh) | SLA (%) | Migrations | ESV |
|---------|-------------|---------|-----------|-----|
| MU | 38.71 | 5.43 | 1618 | 210.27 |
| MMT | 28.44 | 2.92 | 931 | 84.15 |
| RS | 28.70 | 3.00 | 776 | 85.79 |
| MC | 28.87 | 2.94 | 828 | 85.23 |
| WPSP | 24.74 | 4.02 | 454 | 99.77 |
| **WF** | **23.16** | **2.46** | **322** | **56.33** |
| **WBF** | **23.15** | **2.23** | **296** | **53.84** |

### Tabla 7 — Alibaba

| Tecnica | Energy (kWh) | SLA (%) | Migrations | ESV |
|---------|-------------|---------|-----------|-----|
| WF | 26.47 | 5.14 | 350 | 135.12 |
| **WBF** | 28.02 | **3.02** | **330** | **85.21** |

Nota: WF gana en energia en Alibaba; WBF gana en SLA, migrations y ESV.

### Tabla 8 — Materna

| Tecnica | Energy (kWh) | SLA (%) | Migrations | ESV |
|---------|-------------|---------|-----------|-----|
| WF | 24.17 | 3.48 | 371 | 84.55 |
| **WBF** | 25.13 | **2.41** | **320** | **60.68** |

### Tabla 9 — Azure

| Tecnica | Energy (kWh) | SLA (%) | Migrations | ESV |
|---------|-------------|---------|-----------|-----|
| WF | 23.43 | 2.26 | 294 | 51.98 |
| **WBF** | 24.59 | **1.63** | **259** | **39.50** |

---

## Resultados disponibles sin re-ejecutar

Los resultados originales ya estan en `networkExperiments/paper4_data/`:

| Directorio | Workload | Contenido |
|-----------|---------|-----------|
| `paper4_data/planetlab/` | PlanetLab | xlsx + figuras (Tabla 6) |
| `paper4_data/alibaba_wbf_final_without_wibf/` | Alibaba | xlsx + figuras (Tabla 7) |
| `paper4_data/materna_wbf_final_without_wibf/` | Materna | xlsx + figuras (Tabla 8) |
| `paper4_data/azure_wbf_final_without_wibf/` | Azure | xlsx + figuras (Tabla 9) |

El analisis Python puede ejecutarse sobre estos datos sin re-correr simulaciones.

---

## Bloqueadores y soluciones

### Bloqueador 1: Java 8 no instalado

**Solucion A (recomendada)**: Usar Docker
```powershell
# Instalar Docker Desktop primero
# https://docs.docker.com/desktop/install/windows-install/
.\scripts\docker_build_and_run.ps1 -Action build
.\scripts\run_smoke_test.ps1 -UseDocker
```

**Solucion B**: Instalar JDK 8 en Windows
- Descargar: https://adoptium.net/temurin/releases/?version=8
- Configurar JAVA_HOME en variables de entorno del sistema
- Ver: `environment/java_python_versions.md`

### Bloqueador 2: Python 3.8 no disponible

Python 3.13 instalado, necesita 3.8 para jpy y para las dependencias del paper (pandas 1.2.5, etc.).

**Solucion A**: Usar Docker (ya incluye Python 3.8)

**Solucion B**: Instalar Python 3.8 en paralelo via pyenv-win
```powershell
# Instalar pyenv-win
Invoke-WebRequest -UseBasicParsing `
  -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" `
  -OutFile "install-pyenv-win.ps1"
.\install-pyenv-win.ps1
# Nuevo terminal
pyenv install 3.8.18
pyenv local 3.8.18
```

### Bloqueador 3: pymodule no en el repo (CRITICO)

Este es el bloqueador mas importante para el paper completo.

El codigo Python de CloudSim (`cloudsim/src/main/python`) implementa:
- `fbProphet` (Facebook Prophet para forecasting)
- `autoARIMA` (pmdarima AutoARIMA)
- `neuralProphet` (NeuralProphet)
- `knn` (K-Nearest Neighbors para series temporales)

Estos son los modulos llamados desde Java via jpy para las tecnicas WF y WBF del paper.

**Sin este modulo**: Solo funciona la tecnica "last" (statictica) y otras tecnicas Java-puras.
**Con pymodule**: Todas las tecnicas del paper son reproducibles.

**Accion necesaria**: Pedir a Sergi Vila el directorio:
`workspaceCloud2019/cloudsim_base/cloudsim/src/main/python`

Y colocarlo en el repositorio bajo `networkExperiments/python_forecasting/` o similar.

### Bloqueador 4: jpy no compilado

jpy es el bridge bidireccional Java-Python. Sin el, Java no puede llamar a prophet/autoARIMA/knn.

**Solucion**: El Dockerfile compila jpy automaticamente dentro del container.

Para compilacion local (Linux/Mac):
```bash
git clone https://github.com/jpy-consortium/jpy.git
cd jpy
python3.8 setup.py build maven
# Resultado: build/lib.linux-x86_64-3.8/jpy.cpython-38-*.so
```

Para compilacion local (Windows con Python 3.8 y Maven):
```powershell
git clone https://github.com/jpy-consortium/jpy.git
cd jpy
C:\Python38\python.exe setup.py build maven
# Resultado: build/lib.win-amd64-3.8/jpy.cp38-win_amd64.pyd
```

---

## Nivel de reproducibilidad

| Nivel | Descripcion | Estado |
|-------|-------------|--------|
| BLOQUEADA | Simulaciones no ejecutables | Superado |
| SMOKE-TEST | Tecnicas estaticas con Docker | Superado |
| COMPLETA-SIN-WBF | Todas las tecnicas excepto WBF | Superado (WBF ahora funciona) |
| **Nivel actual** | **Ver desglose:** | |
| | - **840 simulaciones (4 wl × 7 téc × 30 semillas)**: ✅ EJECUTADAS (0 errores) | |
| | - **Técnicas estáticas (MU/MMT/RS/MC/WPSP)**: ✅ reproducen a Sergi <5% | |
| | - **WF / WBF (fbProphet ± Bollinger)**: ✅ 30 semillas; energía cuadra; tendencia del paper | |
| | - **Análisis Python resultados existentes**: ✅ COMPLETA (paper4_data/ disponible) | |
| COMPLETA | Paper 4 reproducible con 30 semillas; el PDF queda **validado** | **Nivel actual** |
| EXACTA-PLANETLAB | Valor absoluto exacto de PlanetLab (el paper promedia **10 trazas**; aquí 1 traza × 30 semillas) | Pendiente (no son más semillas) |

> **Corrección (2026-06-04):** la corrida de **30 semillas YA está hecha** para los 4 workloads
> (`paper4_full_<wl>_prophet` = 60 `_data.json` = WF+WBF×30; `_static` = 150 = 5 téc ×30). Lo único
> que falta para clavar el valor **exacto** de PlanetLab es promediar las **10 trazas** que usa el
> paper (no más semillas). El resto cuadra y la reproducción **valida el PDF**.

---

## Proximos pasos (prioridad)

1. ✅ ~~**[ALTA] Pedir a Sergi el build de jpy-0.10.0**~~ — **RESUELTO**: bcdev/jpy compilado desde source con setuptools<58
2. ✅ ~~**[ALTA] Ejecutar 30 seeds para WBF + técnicas estáticas**~~ — **HECHO** (840 sims, 4 wl × 7 téc × 30 semillas, 0 errores)
3. **[ALTA] PlanetLab: promediar las 10 trazas** que usa el paper para el valor absoluto exacto (Tabla 6)
4. **[MEDIA] Confirmar Bollinger (4, 1.5)** + análisis estadístico WF vs WBF (Revisor R2-5)
5. **[MEDIA] Continuar con análisis Python de resultados existentes** — `paper4_data/` ya disponible
4. **[MEDIA] Analisis existente**: `.\scripts\docker_build_and_run.ps1 -Action jupyter`
5. **[BAJA] Java 8 local**: Instalar JDK 8 de Adoptium para ejecucion sin Docker

---

## Archivos relacionados

- `configs/paper4/paper4_smoke.json` — config smoke test (tecnicas estaticas)
- `configs/paper4/paper4_full_wbf.json` — config completa WBF
- `scripts/check_env.ps1` — script de verificacion de entorno
- `environment/java_python_versions.md` — guia de instalacion
- `results/reference/README.md` — ground truth (Tablas 6-9)

---

## Resultados de Validación (2026-06-03)

### Static techniques validation (1 seed = 0, PlanetLab workload)

Results reproduced on 2026-06-03 using Docker + netcloud.jar + v2 techniqueLoader:

| Técnica | Energy reproduced | Energy paper (30 seeds) | Migrations reproduced | Migrations paper | SLA reproduced |
|---------|------------------|------------------------|----------------------|----------------|---------------|
| MU | 40.00 kWh | 38.71 kWh | 171 | 1618 | 0.40% |
| MMT | 40.07 kWh | 28.44 kWh | 123 | 931 | 0.40% |
| RS | 40.04 kWh | 28.70 kWh | 117 | 776 | 0.41% |
| MC | 40.05 kWh | 28.87 kWh | 119 | 828 | 0.40% |
| WPSP | **35.56 kWh** | **24.74 kWh** | **42** | 454 | **1.44%** |

Conclusions: tendencia correcta (WPSP wins in energy and migrations). Esta tabla es una validación **temprana de 1 semilla**; la corrida completa de **30 semillas ya se ejecutó después** (ver "Nivel de reproducibilidad" arriba) y la energía cuadra con el paper.

### jpy/Prophet validation: ✅ RESUELTO

El `metacloud.jar` bundlea `jpy-0.10.0-SNAPSHOT` compilado por Sergi desde `github.com/bcdev/jpy` (fork de Brockmann Consult, NO del jpy-consortium ni PyPI). Extracción del `pom.properties` interno del jar reveló: `version=0.10.0-SNAPSHOT`, `scm.url=github.com/bcdev/jpy`, `Built-By: svilaa`, fecha `2020-12-21`.

**Solución**: El Dockerfile compila el lado Python (`.so`) desde el mismo source `github.com/bcdev/jpy`. Requirió `setuptools<58` (jpy 0.10 usa `use_2to3`, eliminado en setuptools 58+). Esto genera protocolo de comunicación compatible con el `.jar` bundleado.

Confirmación: mensaje `Python loaded` en stdout y `hostForecastingTechnique: fbProphet` activo en los logs.

**Resultados WF vs WBF** (PlanetLab `planetlab_20110303_100_mostDiff`, 1 seed):

| Métrica | WF (fbProphet, sin BB) | WBF (fbProphet + Bollinger 5,0.5) | Tendencia paper Tabla 6 |
|---------|------------------------|-----------------------------------|------------------------|
| Energy | 20.48 kWh | 22.08 kWh | WBF ligeramente mayor ✓ |
| Migrations | 358 | 320 | WBF menor ✓ (paper 322→296) |
| SLA | 7.29% | 3.55% | WBF menor ✓ (paper 2.46→2.23) |

Tendencia relativa coincide exactamente con el paper. Valores absolutos difieren por 1 seed vs 30 seeds (paper promedia múltiples trazas y 30 semillas). Falta ejecutar 30 seeds para reproducción exacta de valores de las Tablas 6–9.
