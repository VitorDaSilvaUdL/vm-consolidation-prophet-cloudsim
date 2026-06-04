# CODE AUDIT — Paper 4: VM Consolidation con Facebook Prophet + Bollinger Bands

**Proyecto:** SVila_Paper4 — Virtual Machine Consolidation Based on Facebook Prophet  
**Venue:** Future Generation Computer Systems (major review 2023)  
**Auditoría ejecutada:** 2026-06-02  
**Máquina:** Windows 11 Pro (PcVIP), Python 3.13.0, Java NO DETECTADO  

---

## 1. Árbol Resumido del Proyecto

```
Proyecto Sergi/
├── networkExperiments/               ← Raíz principal del código
│   ├── metacloud.jar                 (83.8 MB) — simulador CloudSim principal
│   ├── netcloud.jar                  (83.1 MB) — versión para red/netcloud
│   ├── metacloud_*.jar               (8 versiones históricas)
│   ├── launcher.json                 — configuración de rutas y jpy
│   ├── requirements.txt              — dependencias Python (Python 3.8 era objetivo)
│   ├── statistics_paper4.ipynb       — notebook análisis resultados Paper 4
│   ├── statistics_paper4_neural.ipynb
│   ├── statistics_paper4_wpsp.ipynb
│   ├── statistics_paper4_workload_tunning.ipynb
│   ├── statisticsSource.ipynb        — funciones fuente compartidas
│   ├── p4_test3*.ipynb               (11 notebooks de tuning/test)
│   ├── paper4_test_*.ipynb           (varios notebooks de pruebas)
│   ├── BollingerBands*.ipynb         (6 notebooks)
│   ├── ForecastingExperiments.ipynb
│   ├── testbed/                      (359 configs JSON de experimentos)
│   │   ├── paper4_test3.json
│   │   ├── paper4_test3_alibaba_30.json
│   │   ├── paper4_test3_azure_30.json
│   │   ├── paper4_test3_materna_tuning.json
│   │   ├── paper4_test3_planetlab_10traces_30_wpsp.json
│   │   └── [~100 configs paper4_*]
│   ├── experiments/                  (JSONs para poolExperiments)
│   ├── generatedExperiments/         (112 subcarpetas de resultados)
│   ├── paper4_data/                  (resultados finales Paper 4)
│   │   ├── alibaba/                  (.xlsx + 240 .png/.svg)
│   │   ├── azure/                    (.xlsx + imágenes)
│   │   ├── materna/                  (.xlsx + imágenes)
│   │   ├── planetlab/                (.xlsx + imágenes)
│   │   ├── alibaba_wbf*/             (variantes WBF)
│   │   ├── azure_wbf*/
│   │   ├── materna_wbf*/
│   │   └── planetlab_wbf*/
│   ├── workloads/
│   │   ├── planetlab/               (35 archivos)
│   │   ├── materna/                 (34 archivos)
│   │   ├── alibaba2018/             (8 archivos)
│   │   ├── azure/                   (3 archivos)
│   │   ├── alibaba2017/
│   │   ├── bitbrains/
│   │   ├── google2011/
│   │   └── google2019/
│   ├── poolExperiments/
│   ├── topologies/
│   ├── interactions/
│   └── hosts/ vms/ ...
│
├── paper_4_major_review/             ← Documentos de revisión
│   ├── SVila_Paper4_Future_Gen_2023_Major_REV/
│   │   ├── main.tex + secciones .tex
│   │   ├── GO_OUT/ (_figures, _tables, _tex)
│   │   └── figuras .png (alibaba, azure, materna, planetlab)
│   ├── SVila_Paper4_Future_Gen_2023_Major_REV.pdf
│   ├── SVila_Paper4_Future_Gen_2023_Major_REV.zip
│   ├── Paper4_Review_Decision.pdf
│   ├── RV_ Status Report - Paper 4 (...).eml
│   └── referencias_correo_status_report_vitor/
│       └── (3 PDFs referencias)
│
├── CLAUDE.md
├── README.md
├── README_EXPERIMENTS.md             (41 KB — documentación experimentos)
├── README_PYTHON_ANALYSIS.md         (34 KB — documentación análisis Python)
├── prompt_claude_code_paper4_sergi.md
└── project_minimized/                ← (este directorio, creado ahora)
    └── docs/
        └── CODE_AUDIT.md
```

---

## 2. Entorno de Ejecución

### Java

| Item | Estado |
|------|--------|
| Java instalado | **NO — java no encontrado en PATH** |
| JAVA_HOME | **NO configurado** |
| JDK en Program Files | **NO detectado** |
| Compatibilidad JARs | **BLOQUEADO** — metacloud.jar (~84 MB) requiere JDK 8 |

Los JARs fueron compilados para Java 8 (indicado por jpy usando `lib.win-amd64-3.8` en launcher.json). **Java es el bloqueador principal para ejecutar simulaciones.**

### Python

| Item | Valor |
|------|-------|
| Versión instalada | **Python 3.13.0** |
| Versión requerida (requirements.txt) | **Python 3.8** (indicado por rutas jpy `cp38-win_amd64`) |
| Discrepancia | CRÍTICA — diferencia de versión mayor |

### Dependencias Python (estado actual vs. requerido)

| Paquete | Requerido (requirements.txt) | Instalado (Python 3.13) | Estado |
|---------|------------------------------|--------------------------|--------|
| prophet (fbprophet) | Implícito (paper usa Prophet) | **NO** | FALTA |
| neuralprophet | 0.2.7 | **NO** | FALTA |
| pmdarima | 1.8.2 | **NO** | FALTA |
| statsmodels | 0.12.2 | **NO** | FALTA |
| scikit-learn | 0.24.2 | **NO** | FALTA |
| scipy | 1.7.0 | **NO** | FALTA |
| torch | 1.6.0 | **NO** | FALTA |
| openpyxl | — | **NO** | FALTA |
| pandas | 1.2.5 | 3.0.3 (incompatible) | VERSION INCORRECTA |
| numpy | 1.19.5 | 2.4.4 (incompatible) | VERSION INCORRECTA |
| matplotlib | 3.4.2 | 3.10.9 | Compatible (probablemente) |
| jpy | Compilado manualmente | **NO** | FALTA |

**Resumen:** El entorno Python actual (3.13.0) tiene solamente numpy, pandas y matplotlib instalados. **Faltan todas las dependencias científicas críticas del Paper 4.** Además, pandas 3.0.3 y numpy 2.4.4 son versiones mucho más modernas que las requeridas y pueden tener incompatibilidades de API.

---

## 3. Ficheros Esenciales del Paper 4

| Fichero / Recurso | Estado | Notas |
|-------------------|--------|-------|
| `metacloud.jar` | PRESENTE (83.8 MB) | Simulador principal CloudSim |
| `netcloud.jar` | PRESENTE (83.1 MB) | Variante para red |
| `launcher.json` | PRESENTE | Rutas hardcoded a máquina Sergi (ver Sección 5) |
| `requirements.txt` | PRESENTE | Para Python 3.8, no compatible con 3.13 |
| `statistics_paper4.ipynb` | PRESENTE (1.1 MB) | Notebook principal análisis |
| `statisticsSource.ipynb` | PRESENTE (48 KB) | Funciones fuente compartidas |
| `statistics_paper4_neural.ipynb` | PRESENTE (4.5 MB) | Con NeuralProphet |
| `statistics_paper4_wpsp.ipynb` | PRESENTE (4.6 MB) | Con WPSP |
| `paper4_data/alibaba/` | PRESENTE | `alibaba_all.xlsx` + tablas individuales + 12+ imágenes |
| `paper4_data/azure/` | PRESENTE | `azure_all.xlsx` + tablas + imágenes |
| `paper4_data/materna/` | PRESENTE | `materna_all.xlsx` + tablas + imágenes |
| `paper4_data/planetlab/` | PRESENTE | `planetlab_all.xlsx` + 10 tablas trace + imágenes |
| `paper4_data/*_wbf/` | PRESENTE (8 subcarpetas) | Variantes WBF (Weight-Based Forecasting) |
| `workloads/planetlab/` | PRESENTE (35 archivos) | Dataset PlanetLab |
| `workloads/materna/` | PRESENTE (34 archivos) | Dataset Materna |
| `workloads/alibaba2018/` | PRESENTE (8 archivos) | Dataset Alibaba 2018 |
| `workloads/azure/` | PRESENTE (3 archivos) | Dataset Azure |
| `testbed/paper4_test3*.json` | PRESENTE (~100 configs) | Configuraciones experimentos |
| `generatedExperiments/` | PRESENTE (112 carpetas) | Resultados históricos (no todos paper4) |
| `paper_4_major_review/` | PRESENTE | LaTeX completo + PDF |

**Nota sobre paper4_data:** Los datos tienen 511 archivos (30 xlsx + 240 PNG + 240 SVG + 1 RAR). Los xlsx por workload están presentes para los 4 datasets principales: alibaba, azure, materna, planetlab. Los resultados WBF están en subcarpetas separadas. **Los datos para análisis Python existen y están completos.**

---

## 4. Bloqueadores Conocidos (Priorizados)

### CRÍTICO — Impide cualquier ejecución

**B1. Java no instalado**
- `java` no existe en PATH, JAVA_HOME no configurado
- Sin Java no se puede ejecutar `metacloud.jar`
- Se requiere JDK 8 (Java 8 / 1.8) para compatibilidad con jpy compilado para Python 3.8
- Solución: Instalar OpenJDK 8 (e.g., Adoptium Temurin 8) y configurar JAVA_HOME

**B2. jpy no disponible**
- `jpy` no está instalado como módulo Python
- `launcher.json` apunta a `jpy.cp38-win_amd64.pyd` en máquina Sergi (no existe aquí)
- jpy es el puente Java-Python que permite llamar CloudSim desde Python
- Solución: Compilar jpy para Python 3.8 + JDK 8, o usar Python 3.8 con binario precompilado

**B3. Python 3.13 incompatible con el stack**
- El proyecto requiere Python 3.8 (rutas jpy, torch 1.6.0, versiones de paquetes en requirements.txt)
- Python 3.13 no es compatible con `torch==1.6.0`, `neuralprophet==0.2.7`, ni `pmdarima==1.8.2`
- Solución: Crear entorno virtual Python 3.8 (venv o conda)

### ALTO — Impide análisis Python aunque no impide leer datos

**B4. Dependencias Python críticas no instaladas**
Las siguientes librerías no están instaladas en el entorno actual:
- `prophet` / `fbprophet` — técnica central del paper
- `neuralprophet==0.2.7` — extensión neural de Prophet
- `pmdarima==1.8.2` — AutoARIMA (baseline comparado)
- `statsmodels==0.12.2` — modelos estadísticos (ETS, etc.)
- `scipy==1.7.0` — cálculos científicos
- `scikit-learn==0.24.2` — KNN forecasting
- `torch==1.6.0` — backend de NeuralProphet
- `openpyxl` — lectura/escritura de .xlsx

**B5. Rutas hardcoded a máquina Sergi en launcher.json**
Ver Sección 5 para detalle.

### MEDIO — Impide reproducción completa pero no análisis de datos existentes

**B6. generatedExperiments/ no tiene resultados paper4 nombrados explícitamente**
- La carpeta tiene 112 subcarpetas pero ninguna con nombre `paper4_*`
- Los resultados finales consolidados están en `paper4_data/` (xlsx e imágenes)
- Los JSONs de simulación bruta probablemente están en las subcarpetas `paper4_data/*/` (no se detectaron .json)

---

## 5. Rutas Hardcoded Detectadas

### `networkExperiments/launcher.json`

```json
{
    "baseFolder": "C:\\Users\\Sergi\\Documents\\networkExperiments",
    "experimentsFolder": "testbed",
    "outputFolder": "generatedExperiments",
    "experiment": "test",
    "jpyLib": "C:\\Users\\Sergi\\Documents\\jpy\\build\\lib.win-amd64-3.8\\jpy.cp38-win_amd64.pyd",
    "jdlLib": "C:\\Users\\Sergi\\Documents\\jpy\\build\\lib.win-amd64-3.8\\jdl.cp38-win_amd64.pyd",
    "decisionLogger": "C:\\Users\\Sergi\\Documents\\networkExperiments\\debugLog.txt",
    "pymodule": "C:/Users/PcVIP/Desktop/Proyecto Sergi/networkExperiments/svila_phd_metacloudsim/cloudsim/src/main/python"
}
```

**Rutas que deben actualizarse para esta máquina (PcVIP):**

| Campo | Ruta Sergi (actual) | Ruta PcVIP (requerida) |
|-------|---------------------|------------------------|
| `baseFolder` | `C:\Users\Sergi\Documents\networkExperiments` | `C:\Users\PcVIP\Desktop\Proyecto Sergi\networkExperiments` |
| `jpyLib` | `C:\Users\Sergi\Documents\jpy\build\lib.win-amd64-3.8\jpy.cp38-win_amd64.pyd` | Path al jpy compilado en PcVIP |
| `jdlLib` | `C:\Users\Sergi\Documents\jpy\build\lib.win-amd64-3.8\jdl.cp38-win_amd64.pyd` | Path al jdl compilado en PcVIP |
| `decisionLogger` | `C:\Users\Sergi\Documents\networkExperiments\debugLog.txt` | `C:\Users\PcVIP\Desktop\Proyecto Sergi\networkExperiments\debugLog.txt` |
| `pymodule` | `C:/Users/Sergi/Documents/workspaceCloud2019/cloudsim_base/...` | ✅ Disponible en `networkExperiments/svila_phd_metacloudsim/cloudsim/src/main/python` |

**~~Resuelto~~:** El módulo Python está disponible en `networkExperiments/svila_phd_metacloudsim/cloudsim/src/main/python` (añadido 2026-06-03). Contiene: forecastingTechniques.py, bollingerFunctions.py, signalProcessing.py, pythonBinding.py.

---

## 6. Relación Java ↔ Python ↔ Notebooks

### Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                     CAPA DE SIMULACIÓN                       │
│                                                             │
│  metacloud.jar (CloudSim modificado)                        │
│  ├── VM Consolidation engine                                │
│  ├── Host allocation policies (future, cs metrics)          │
│  ├── Selection policies (mu, psp2, rs, mmt, mc)             │
│  ├── Migration policies (ac, bfd, dr, etc.)                 │
│  └── Oversaturation detection (mad, iqr, thr, lr, lrr)     │
│                        ↕ jpy bridge                         │
│  Módulo Python (pymodule — ✅ disponible en svila_phd_metacloudsim) │
│  ├── Forecasting techniques: fbProphet, neuralProphet,      │
│  │   autoArima, knn, perc95, etc.                           │
│  ├── Signal processing: bollinger, interpeaks, interbollinger│
│  └── Orquestación de experimentos desde launcher.json       │
└─────────────────────────────────────────────────────────────┘
                           ↓ outputs JSON/xlsx
┌─────────────────────────────────────────────────────────────┐
│                    CAPA DE ANÁLISIS                          │
│                                                             │
│  statistics_paper4.ipynb                                    │
│  ├── Lee paper4_data/*.xlsx                                 │
│  ├── Genera tablas comparativas (métricas SLA, energía,     │
│  │   migraciones, ESV, ratio ME)                            │
│  └── Produce figuras para el paper LaTeX                    │
│                                                             │
│  p4_test3_*.ipynb (11 notebooks)                            │
│  ├── Experimentos de tuning de parámetros Bollinger         │
│  ├── Comparativas por workload (alibaba, azure, materna,    │
│  │   planetlab)                                             │
│  └── Análisis WBF (Weight-Based Forecasting)                │
└─────────────────────────────────────────────────────────────┘
```

### Qué hace el JAR (CloudSim)
`metacloud.jar` es una extensión de CloudSim 3.x que implementa consolidación dinámica de VMs con soporte para:
- Predicción de utilización de recursos (CPU, RAM, BW) vía `forecastingTechnique`
- Preprocesamiento de señales (Bollinger Bands, interpeaks) vía `signalProcessing`
- Políticas de selección/migración/asignación configurables por JSON
- Topologías de red (fat-tree) y simulación de tráfico

### Integración Java-Python via jpy
- `jpy` (Java-Python bridge) permite que código Python llame clases Java en tiempo de ejecución
- El `pymodule` Python implementa las técnicas de predicción (fbProphet, NeuralProphet, AutoARIMA) que el JAR llama para obtener forecasts
- El launcher.json configura qué técnicas usar; el JAR llama al módulo Python cuando se activa `forecastingTechnique: fbProphet` o `neuralProphet`

### Qué técnicas necesitan jpy vs. cuáles son solo Java
| Técnica en testbed JSON | Requiere jpy | Solo Java |
|-------------------------|:------------:|:---------:|
| `last`, `mean`, `perc95`, `percX` | — | Java |
| `knn` | — | Java |
| `simpleExpSmoothing`, `holtExpSmoothing` | — | Java |
| `holtWintersExpSmoothing` | — | Java |
| **`fbProphet`** | **SÍ** | — |
| **`neuralProphet`** | **SÍ** | — |
| **`autoArima`** | **SÍ** | — |
| `bollinger`, `interpeaks`, `interbollinger` (signal) | Depende de config | Java si no hay forecast |

### Qué hacen los notebooks de análisis
Los notebooks `statistics_paper4.ipynb` y `p4_test3_*.ipynb` leen directamente los archivos `.xlsx` de `paper4_data/` y **NO requieren Java ni jpy**. Generan tablas, gráficos y estadísticas a partir de resultados pre-calculados. **Estos notebooks pueden ejecutarse sin las simulaciones si se tienen los xlsx.**

---

## 7. Estado de Resultados Existentes

### ¿paper4_data/ tiene los xlsx de los 4 workloads?

**SÍ, están presentes y completos:**

| Workload | xlsx principal | xlsx individuales | Imágenes |
|----------|---------------|-------------------|----------|
| Alibaba (2018) | `alibaba_all.xlsx` | `alibaba_table_alibaba2018_fixed_first_500_100_mostDiff.xlsx` | ~12 PNG + 12 SVG |
| Azure | `azure_all.xlsx` | `azure_table_azure_azure2019_traces_100_mostDiff.xlsx` | ~12 PNG + 12 SVG |
| Materna | `materna_all.xlsx` | `materna_table_materna_trace1_valid_0_288_100_mostDiff.xlsx` | ~12 PNG + 12 SVG |
| PlanetLab | `planetlab_all.xlsx` | 10 tablas trace (20110303 a 20110420) | ~12 PNG + 12 SVG |

Además, hay subcarpetas `*_wbf*/` con variantes de los 4 workloads para los experimentos de WBF y la versión final sin WIBF. Total: **511 archivos** en paper4_data, incluyendo 30 xlsx.

### ¿generatedExperiments/ tiene resultados paper4?

Los 112 subdirectorios de `generatedExperiments/` corresponden mayoritariamente a experimentos anteriores (AINA, ccgrid, europar, etc.). **No se detectaron carpetas con naming explícito `paper4_*` en generatedExperiments.** Los resultados consolidados del Paper 4 están directamente en `paper4_data/`.

### ¿Se puede hacer análisis Python sin re-ejecutar simulaciones?

**SÍ, parcialmente — con instalación de dependencias:**

Los xlsx existen y contienen métricas de simulación (SLA, energía, migraciones, ESV, ratio ME). Para ejecutar los notebooks de análisis se necesita instalar:
- `pandas` compatible (≥1.x, ≤2.x recomendado)
- `matplotlib`
- `openpyxl` (lectura .xlsx)
- `scipy` (estadísticas)
- `statsmodels` (si algún notebook lo usa)

**Lo que NO se puede hacer sin Java+jpy:** Re-ejecutar las simulaciones de CloudSim para generar nuevos xlsx.

---

## 8. Recomendaciones (Por Prioridad)

### Prioridad 1: Análisis Python de datos existentes (SIN Java)

Permite revisar/reproducir tablas y figuras del paper usando datos ya calculados.

1. **Instalar Python 3.8** en un entorno virtual separado (o usar conda):
   ```
   conda create -n paper4 python=3.8
   conda activate paper4
   ```
2. **Instalar dependencias** usando el requirements.txt del proyecto:
   ```
   pip install -r networkExperiments/requirements.txt
   ```
   Nota: `fbprophet` fue renombrado a `prophet` en 2021. Puede requerir:
   ```
   pip install prophet  # en lugar de fbprophet
   ```
3. **Ajustar pandas API** en notebooks si es necesario (pandas 1.2.5 vs 3.x tienen diferencias de API)
4. **Ejecutar** `statistics_paper4.ipynb` con kernel del entorno paper4

### Prioridad 2: Reproducción completa (CON Java)

Permite re-ejecutar las simulaciones CloudSim para validar resultados.

5. **Instalar JDK 8** (OpenJDK / Adoptium Temurin 8 para Windows):
   - URL: https://adoptium.net/temurin/releases/?version=8
   - Configurar `JAVA_HOME` y agregar `%JAVA_HOME%\bin` al PATH
6. **Compilar jpy** para Python 3.8 + JDK 8:
   - Clonar https://github.com/jpy-consortium/jpy
   - Seguir instrucciones de build para Windows
7. **~~Obtener el módulo Python de CloudSim~~ (`pymodule`) ✅ Resuelto (2026-06-03)**:
   - Disponible en `networkExperiments/svila_phd_metacloudsim/cloudsim/src/main/python`
   - Contiene: forecastingTechniques.py, bollingerFunctions.py, signalProcessing.py, pythonBinding.py
8. **Actualizar launcher.json** con las rutas de la máquina PcVIP:
   ```json
   {
     "baseFolder": "C:\\Users\\PcVIP\\Desktop\\Proyecto Sergi\\networkExperiments",
     "jpyLib": "<ruta a jpy compilado para Python 3.8>",
     "jdlLib": "<ruta a jdl compilado para Python 3.8>",
     "decisionLogger": "C:\\Users\\PcVIP\\Desktop\\Proyecto Sergi\\networkExperiments\\debugLog.txt",
     "pymodule": "<ruta al módulo Python de CloudSim>"
   }
   ```

### Prioridad 3: Major Review — Cambios que requieren nueva simulación

Para los cambios solicitados en el major review que impliquen nuevas configuraciones de experimentos:

9. **Identificar qué experimentos deben re-ejecutarse** revisando `paper_4_major_review/4_experimentation.tex`
10. **Crear nuevas configs JSON** en `testbed/` basadas en las existentes `paper4_test3_*.json`
11. **Ejecutar via launcher** con Java+jpy funcionando
12. **Analizar nuevos resultados** con los notebooks de statistics

### Consideraciones adicionales

- **No existe requirements_paper4.txt minimal:** el requirements.txt incluye 80+ paquetes para todos los papers (AINA, ccgrid, europar, paper3, paper4). Considerar crear uno minimal solo para paper4.
- **neuralprophet 0.2.7 es obsoleto:** La versión actual es 0.9+; puede requerir adaptar código de los notebooks.
- **torch 1.6.0 es incompatible con Python 3.8+ actual:** Instalar via pip wheel específico o usar conda para resolución de dependencias.
- **Los workloads de bitbrains no están** en `workloads/` aunque aparecen en configs paper4; están en `workloads_ddbb/` o puede que falten.

---

*Auditoría generada automáticamente. Datos verificados directamente del filesystem el 2026-06-02.*
