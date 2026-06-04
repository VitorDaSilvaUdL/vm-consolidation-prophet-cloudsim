# Informe de Minimizacion del Proyecto — Paper 4

**Fecha**: 2026-06-02
**Autor**: Research Software Engineer (analisis automatico)
**Proyecto original**: `networkExperiments/` (MetaCloudSim, UdL INSPIRES)

---

## Proposito de la minimizacion

Crear una estructura autocontenida y documentada que permita:
1. Verificar el entorno antes de ejecutar
2. Ejecutar el smoke test con el minimo de dependencias
3. Analizar los resultados existentes sin re-ejecutar simulaciones
4. Reproducir el experimento completo cuando el entorno este listo
5. Documentar claramente que falta y como obtenerlo

---

## Inventario del proyecto original

`networkExperiments/` contiene:

| Categoria | Tamano estimado | Descripcion |
|----------|-----------------|-------------|
| JARs (metacloud*.jar, netcloud*.jar) | ~850 MB | Versiones del simulador |
| Notebooks Jupyter (*.ipynb) | ~200 MB | 90+ notebooks de analisis |
| Workloads (workloads/) | ~5 GB | Trazas PlanetLab, Alibaba, Materna, Azure |
| paper4_data/ | ~500 MB | Resultados del paper (xlsx + figuras) |
| poolExperiments/ | >10 GB | Experimentos historicos |
| generatedExperiments/ | ~2 GB | Output de experimentos locales |
| Otros notebooks grandes (*.rar) | ~200 MB | Notebooks archivados |
| testbed/*.json | ~5 MB | 100+ configuraciones de experimentos |
| Codigo Python notebooks | incluido en ipynb | |

**Total estimado**: >15 GB

---

## Que se INCLUYE en project_minimized/

### Copiado directamente del proyecto original

| Origen | Destino | Razon |
|--------|---------|-------|
| `networkExperiments/requirements.txt` | `environment/requirements.txt` | Dependencias exactas del paper (84 paquetes) |
| `networkExperiments/statistics_paper4.ipynb` | `python/notebooks/statistics_paper4.ipynb` | Notebook principal de analisis del paper |
| `networkExperiments/statisticsSource.ipynb` | `python/notebooks/statisticsSource.ipynb` | Notebook fuente con funciones comunes |
| `networkExperiments/testbed/paper4_test_plus_o.json` | `configs/paper4/paper4_full_wbf.json` | Config completa del experimento WBF |

### Creado nuevo en project_minimized/

| Fichero | Razon |
|---------|-------|
| `Dockerfile` | Entorno reproducible Java 8 + Python 3.8 + jpy |
| `docker-compose.yml` | Orquestacion: simulacion + jupyter |
| `.dockerignore` | Excluir ficheros grandes del build context |
| `environment/requirements_docker.txt` | Requirements limpio para Docker (sin torch por tamano) |
| `environment/java_python_versions.md` | Guia de instalacion de versiones exactas |
| `configs/launcher.example.json` | Template launcher.json con placeholders |
| `configs/launcher_docker.json` | Launcher pre-configurado para Docker |
| `configs/paper4/paper4_smoke.json` | Config minima smoke test sin jpy |
| `scripts/check_env.ps1` | Verificacion automatica del entorno |
| `scripts/run_smoke_test.ps1` | Ejecucion smoke test (con/sin Docker) |
| `scripts/run_paper4_full.ps1` | Ejecucion experimento completo |
| `scripts/run_analysis.py` | Analisis resultados existentes |
| `scripts/docker_build_and_run.ps1` | Helper Docker build + run |
| `data/README_DATA.md` | Documentacion de donde estan los datos |
| `results/reference/README.md` | Ground truth: Tablas 6-9 del paper |
| `docs/REPRODUCIBILITY_REPORT.md` | Estado detallado de reproducibilidad |
| `docs/PROJECT_MINIMIZATION_REPORT.md` | Este fichero |

---

## Que se EXCLUYE y por que

### Excluido por tamano

| Excluido | Tamano | Razon |
|----------|--------|-------|
| `networkExperiments/*.jar` | ~850 MB total | Se accede via volume mount en Docker |
| `networkExperiments/workloads/` | ~5 GB | Se accede via volume mount |
| `networkExperiments/poolExperiments/` | >10 GB | Experimentos historicos innecesarios para reproducir Paper 4 |
| `networkExperiments/generatedExperiments/` | ~2 GB | Output local, no reproduccion |
| `networkExperiments/*.rar` | ~200 MB | Archives, no necesarios |
| `networkExperiments/planetlab_vms.db` | ~400 MB | Base de datos local |
| `networkExperiments/jupyterlab_notebooks.rar` | ~65 MB | Archive de notebooks |

### Excluido por ser irrelevante para Paper 4

| Excluido | Razon |
|----------|-------|
| `networkExperiments/statistics_paper3*.ipynb` (6 ficheros) | Paper 3, no Paper 4 |
| `networkExperiments/AINA_CCGRID_data/` | Datos de conferencias anteriores |
| `networkExperiments/paper3_data*` | Resultados Paper 3 |
| 70+ notebooks no relacionados con Paper 4 | ForecastingExperiments, BollingerBands, etc. |
| `networkExperiments/testbed/*.json` (100+ ficheros) | Solo se incluyen las configs del Paper 4 |
| `networkExperiments/poolExperiments/` | Pool de experimentos de la maquina de Sergi |
| Scripts HPC (qsub*.sh, send.ps1, remote/) | Infraestructura HPC de la UdL, no reproducible localmente |

### Excluido por no estar disponible

| No disponible | Estado | Impacto |
|--------------|--------|---------|
| `pymodule` (cloudsim/src/main/python) | ✅ Disponible en `networkExperiments/svila_phd_metacloudsim/cloudsim/src/main/python` (2026-06-03) | WBF ahora ejecutable |
| Trazas workload originales completas | En workloads/ (no copiadas) | Acceder via volume mount |

---

## Estructura final creada

```
project_minimized/                        # Raiz del proyecto minimizado
├── README.md                             # Guia de inicio rapido
├── Dockerfile                            # ubuntu:20.04 + Java 8 + Python 3.8 + jpy
├── docker-compose.yml                    # Servicios: metacloudsim, jupyter, metacloudsim-wbf
├── .dockerignore                         # Excluye jars, db, generatedExperiments
├── environment/
│   ├── requirements.txt                  # COPIADO: 84 paquetes originales
│   ├── requirements_docker.txt           # NUEVO: version limpia para Docker
│   └── java_python_versions.md           # NUEVO: guia de versiones e instalacion
├── configs/
│   ├── launcher.example.json             # NUEVO: template con placeholders
│   ├── launcher_docker.json              # NUEVO: paths para container Docker
│   └── paper4/
│       ├── paper4_smoke.json             # NUEVO: config minima smoke test (no jpy)
│       └── paper4_full_wbf.json          # COPIADO: config completa WBF
├── scripts/
│   ├── check_env.ps1                     # NUEVO: verificacion entorno completo
│   ├── run_smoke_test.ps1                # NUEVO: smoke test con/sin Docker
│   ├── run_paper4_full.ps1               # NUEVO: experimento completo WBF
│   ├── run_analysis.py                   # NUEVO: analisis resultados existentes
│   └── docker_build_and_run.ps1          # NUEVO: helper Docker
├── python/
│   └── notebooks/
│       ├── statistics_paper4.ipynb       # COPIADO de networkExperiments/
│       └── statisticsSource.ipynb        # COPIADO de networkExperiments/
├── data/
│   └── README_DATA.md                    # NUEVO: donde estan los datos
├── results/
│   ├── reference/
│   │   └── README.md                     # NUEVO: ground truth Tablas 6-9
│   └── smoke_test/                       # VACIO: output del smoke test
└── docs/
    ├── CODE_AUDIT.md                     # PREEXISTENTE
    ├── PAPER4_SPECS.md                   # PREEXISTENTE
    ├── REPRODUCIBILITY_REPORT.md         # NUEVO: estado reproducibilidad
    └── PROJECT_MINIMIZATION_REPORT.md    # NUEVO: este fichero
```

---

## Scripts creados — proposito y uso

| Script | Lenguaje | Proposito | Cuando usar |
|--------|----------|-----------|-------------|
| `check_env.ps1` | PowerShell | Verificar Java 8, Python 3.8, jpy, prophet, Docker | Antes de cualquier ejecucion |
| `run_smoke_test.ps1` | PowerShell | Smoke test con tecnicas estaticas | Primera prueba de que el simulador arranca |
| `run_paper4_full.ps1` | PowerShell | Experimento completo WBF (4 workloads) | Cuando pymodule disponible |
| `run_analysis.py` | Python 3 | Analisis de paper4_data/ existente | Para analizar resultados sin re-ejecutar |
| `docker_build_and_run.ps1` | PowerShell | Build + run Docker simplificado | Gestion completa del entorno Docker |

---

## Diferencias respecto al proyecto original

| Aspecto | Proyecto original | project_minimized/ |
|---------|-------------------|--------------------|
| Estructura | Plana (todo en networkExperiments/) | Organizada por proposito |
| Launcher | Paths hardcoded a Sergi | Template con placeholders + version Docker |
| Documentacion | Ausente | CODE_AUDIT, PAPER4_SPECS, REPRODUCIBILITY, minimizacion |
| Docker | Dockerfile basico (Ubuntu + Java) | Completo: jpy + Python 3.8 + deps |
| Scripts | Send.ps1 para HPC | Scripts locales para PcVIP |
| Notebooks | 90+ en raiz de networkExperiments/ | 2 relevantes para Paper 4 |
| Configs | 100+ JSONs en testbed/ | 2 JSONs esenciales (smoke + full WBF) |
| Tamaño estimado | >15 GB | ~50 MB (sin notebooks copiados, los jars no se copian) |

---

## Riesgos y deuda tecnica

### ~~Riesgo 1 (CRITICO): pymodule ausente~~ ✅ Resuelto (2026-06-03)
pymodule disponible en `networkExperiments/svila_phd_metacloudsim/cloudsim/src/main/python`.
Contiene: forecastingTechniques.py, bollingerFunctions.py, signalProcessing.py, pythonBinding.py, traceImporter.py.
WBF, WF, fbProphet, autoARIMA, neuralProphet ahora reproducibles con Docker + jpy.

### Riesgo 2 (ALTO): Compatibilidad jpy en Docker
jpy se compila en tiempo de build. Si la version de Python en ubuntu:20.04 cambia, puede fallar.
**Mitigacion**: Dockerfile especifica `python3.8` explicitamente. Versiones ancladas.

### Riesgo 3 (MEDIO): requirements.txt con 84 paquetes de 2021
Algunos paquetes pueden haber sido deprecados o tener conflictos en Python 3.8.
`requirements_docker.txt` solo incluye los esenciales para evitar conflictos.
**Mitigacion**: Probar con `requirements_docker.txt` primero; usar `requirements.txt` original si falta algo.

### Riesgo 4 (BAJO): paper4_smoke.json — workload `planetlab_100_mostDiff`
Este workload debe existir en `networkExperiments/workloads/planetlab/`.
Si no existe con ese nombre exacto, el smoke test falla con un error del simulador.
**Mitigacion**: Script `run_smoke_test.ps1` da instrucciones detalladas si falla.

### Riesgo 5 (BAJO): Notebooks copiados pueden desincronizarse
Si Sergi actualiza `statistics_paper4.ipynb`, la copia en `python/notebooks/` quedara desfasada.
**Mitigacion**: Documentado. Los notebooks son para analisis, no para simulacion.

### Deuda tecnica

- Los resultados del smoke test deben compararse manualmente con los valores de referencia.
  No hay test automatico de "los resultados coinciden con Tabla 6".
- El Dockerfile no tiene tests de integracion para verificar que jpy funciona tras el build.
- `run_analysis.py` genera un summary basico; el analisis completo sigue requiriendo Jupyter manual.
