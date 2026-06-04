# Paper 4 — Especificaciones Exactas del Experimento

**Titulo del paper**: VM Consolidation using WBF (WPSP + Bollinger Bands + Facebook Prophet)  
**Revista destino**: Future Generation Computer Systems (FGCS)  
**Estado**: Major Review recibido  
**Simulador**: MetaCloudSim (basado en CloudSim)  
**Codigo fuente**: https://bitbucket.org/svila_phd/metacloudsim/src/vmAllocation/

---

## 1. Configuracion exacta del experimento Paper 4

Los experimentos finales del Paper 4 se basan en los configs de la familia `paper4_test3_*_wbf` y `paper4_test3_*_30` (con 30 seeds), todos con la misma estructura base documentada abajo.

### Fichero de referencia principal

`networkExperiments/testbed/paper4_test3_alibaba_30_wbf.json`  
(idem para planetlab, materna, azure — solo cambia `workloadTrace`)

### Politicas de asignacion y migracion

| Parametro               | Valor                        |
|-------------------------|------------------------------|
| `allocationPolicy`      | `"custom"`                   |
| `techniqueLoader`       | `"v3"`                       |
| `selectionPolicy`       | `"psp2"` (WPSP)              |
| `selectionMode`         | `"first"`                    |
| `vmMigrationPolicy`     | `"ac"` (Absolute Capacity)   |
| `vmOptimizerPolicy`     | `"future"`                   |
| `hostOverSaturationPolicy` | `"mad"` (MAD)             |
| `hostUnderUtilisationPolicy` | `"def"`                 |

### Tecnicas comparadas — hostForecastingTechnique

El campo activo en los experimentos del paper es:

```json
"hostForecastingTechnique": [["last"]]
```

El campo `___hostForecastingTechnique` (comentado/referencia) muestra la lista completa de tecnicas disponibles:

```json
[["last"], ["mean"], ["perc95"], ["neuralProphet"],
 ["knn", 5], ["percX", 0.8], ["fbProphet"], ["autoArima"],
 ["simpleExpSmoothing", 0.8], ["holtExpSmoothing", 0.8, 0.2],
 ["holtWintersExpSmoothing", 0.8, 0.2, -1, -1]]
```

Las **7 tecnicas comparadas en el paper** son:

| Etiqueta Paper | selectionPolicy       | hostForecastingTechnique | hostSignalProcessing  |
|----------------|-----------------------|--------------------------|-----------------------|
| MU             | `mu`                  | `["last"]`               | `["none"]`            |
| MMT            | `mmt`                 | `["last"]`               | `["none"]`            |
| RS             | `rs`                  | `["last"]`               | `["none"]`            |
| MC             | `mc`                  | `["last"]`               | `["none"]`            |
| WPSP           | `psp2`                | `["last"]`               | `["none"]`            |
| WF             | `psp2`                | `["fbProphet"]`          | `["none"]`            |
| WBF (propuesta)| `psp2`                | `["fbProphet"]`          | `["bollinger", 5, 0.5]` |

> Nota: el config `paper4_test_plus_o.json` muestra en el override WBF: `hostSignalProcessing: ["bollinger", 5, 0.5]`.
> El config base usa `["none"]` y la variante con bollinger activa el override.

### hostSignalProcessing — variantes evaluadas

- Sin Bollinger (WF): `["none"]`
- Con Bollinger (WBF): `["bollinger", 5, 0.5]` — ventana=5, alpha=0.5
- Variante calibracion (no en paper final): `["bollinger", 4, 1.5]`
- Alternativa interpeaks: `["interpeaks", 3, 0.1..2.0]` (explorada pero no en resultados finales)

### Parametros de simulacion

| Parametro                   | Valor                         |
|-----------------------------|-------------------------------|
| `simulationTimeLimit`       | `86400` s (1 dia)             |
| `migrationInterval`         | `6` (cada 6 pasos)            |
| `numCloudlets`              | `100` VMs                     |
| `randomSeed`                | `[0..29]` — 30 semillas       |
| `forecastingHistoryLength`  | `30` pasos en el pasado       |
| `defaultHistoryLength`      | `30`                          |
| `utilizationThreshold`      | `1.0`                         |
| `hostAllocationUtilization` | `0.4` (40%)                   |
| `tunningValue`              | `0.65` (umbral Pearson WPSP)  |
| `isTunning`                 | `true`                        |
| `dynamicResources`          | `["CPU", "BW", "RAM"]`        |
| `internalClusterRate`       | `0.05` (5% interacciones internas) |
| `externalClusterRate`       | `0.01` (1% externas)          |
| `network`                   | `true`                        |
| `dataStartStep`             | `0`                           |
| `mipsStatsInterpolation`    | `false`                       |

### Topologia, Hosts y VMs

| Parametro        | Valor                                            |
|------------------|--------------------------------------------------|
| `topology`       | `"fatTreeTopology_k-2_g-2_s-2_hs-2_h-16"`       |
| `hosts`          | `"testHostsOneCore"`                             |
| `hostsDistribution` | `[1, 1]` (8 Small + 8 Large = 16 hosts)       |
| `vms`            | `"vms4"`                                         |
| `vmsDistribution`| `[1, 2, 3, 4, 5]` (proporciones de tamanos VM)   |

**Detalles topologia Fat-Tree 3 capas** (del paper, Table 3):
- k=2, grupos=2, switches por nivel=2, hosts por switch=2
- Total hosts: 16 (8 Small HP ML110 G4 + 8 Large HP ML110 G5)
- Total switches: 20
- BW Host-VM: 100 Mbps
- BW Host-Switch: 1000 Mbps
- Max BW interacciones: 3 Mbps

**Hosts** (Table 2 del paper):

| Tipo  | Modelo       | CPUs | MIPS | BW (Mbps) | Arranque (J) | Apagado (J) | Cantidad |
|-------|--------------|------|------|-----------|--------------|-------------|----------|
| Small | HP ML110 G4  | 2    | 1860 | 1000      | 21057 (son 43020 arranque total) | 5560 | 8 |
| Large | HP ML110 G5  | 2    | 2660 | 1000      | 30114 (arranque total) | 3892 | 8 |

> Nota precision energia: el paper (Section 3.1) usa 43020 J para start-up y 5560 J para shutdown (valores del modelo energetico extendido de Sarji et al.), mientras Table 2 muestra valores de la hoja de datos del hardware.

**VMs por workload** (Table 4 del paper):

| Workload  | Tiny (500/2000 MIPS) | Small (1000/3000 MIPS) | Medium (2000/4000 MIPS) | Large (2500/5000 MIPS) |
|-----------|----------------------|------------------------|-------------------------|------------------------|
| PlanetLab | 38                   | 31                     | 23                      | 8                      |
| Alibaba   | 40                   | 30                     | 20                      | 10                     |
| Materna   | 27                   | 33                     | 27                      | 13                     |
| MS Azure  | 23                   | 38                     | 31                      | 8                      |

> Total: siempre 100 VMs. MIPS para PlanetLab/Alibaba: 500/1000/2000/2500. Para Materna/Azure: 2000/3000/4000/5000.

### Interacciones entre VMs

```json
"interactions": [["fnss3000_0_20", "fnss3000_20_60", "fnss3000_60_95"]],
"interactionsDistribution": [[5, 3, 2]]
```

### Parametros Bollinger Bands (del paper, Section 3.2)

- Ventana N: tipicamente 20 en bolsa, ajustado a 5 en los experimentos
- Amplitud alpha: 2.0 en bolsa (95% cobertura); ajustado a 0.5 en los experimentos
- Formula: `UB = SMA + alpha * sigma`, `LB = SMA - alpha * sigma`

### Parametros Facebook Prophet (del paper, Section 3.3)

- Entrenamiento: al inicio de cada proceso de migracion
- Datos de entrada: 30 pasos de simulacion en el pasado (periodos de 5 minutos)
- Duracion entrenamiento: hasta 1.5 segundos
- Modelo: serie temporal aditiva `y(t) = g(t) + s(t) + h(t) + epsilon_t`
- Hiper-parametros: definidos por cross-validation por VM

---

## 2. Pool experiments correspondientes al Paper 4

Los pools de `networkExperiments/poolExperiments/` que corresponden a los experimentos finales del paper son:

### Pools de resultados finales (paper final, 30 seeds)

| Pool                                           | Descripcion                                      | Estado estimado |
|------------------------------------------------|--------------------------------------------------|-----------------|
| `pool_paper4_test3_planetlab_10traces_30_wbf_o`| PlanetLab, 30 seeds, WBF + comparativas          | Completado      |
| `pool_paper4_test3_alibaba_azure_30_o`         | Alibaba + Azure, 30 seeds                        | Completado      |
| `pool_paper4_test3_azure_materna_alibaba_30_wbf_o` | Azure + Materna + Alibaba, WBF 30 seeds     | Completado      |
| `pool_paper4_test3_materna_30_wbf_o`           | Materna, 30 seeds, WBF                           | Completado      |
| `pool_paper4_test3_azure_30_2_o`               | Azure 30 seeds (version 2)                       | Completado      |

### Pools de comparativas base (MU/MMT/RS/MC)

| Pool                                           | Descripcion                                      |
|------------------------------------------------|--------------------------------------------------|
| `pool_paper4_test2_main_workload_mu_wpsp_fix_o`| MU+WPSP workload principal, fix aplicado         |
| `pool_paper4_test2_main_workload_mu_wpsp_o`    | MU+WPSP workload principal                       |
| `pool_paper4_test3_planetlab_10traces_30_wpsp_o`| WPSP solo, PlanetLab, 30 seeds                  |

### Pools de tuning/calibracion (no en resultados finales)

| Pool                                           | Descripcion                                      |
|------------------------------------------------|--------------------------------------------------|
| `pool_paper4_test3_materna_tuning_30_o`        | Calibracion Materna                              |
| `pool_paper4_test3_materna_tuning_hindex2_o`   | Calibracion h-index Materna                      |
| `pool_paper4_test_facebook_bollinger_o`        | Tuning fbProphet + Bollinger                     |
| `pool_paper4_test_plus_o`                      | Tuning general (interpeaks + bollinger)          |
| `pool_paper4_test_auto_arima_o`                | Exploracion autoArima                            |
| `pool_paper4_test_facebook_neural_o`           | Exploracion NeuralProphet                        |
| `pool_paper4_test_allw_pre_o`                  | Pre-experimento todos los workloads              |

---

## 3. Dependencias Python por tecnica

| Tecnica                    | Necesita jpy | Modulo Python       | Notas                                                        |
|----------------------------|-------------|---------------------|--------------------------------------------------------------|
| `last`                     | No          | —                   | Solo Java, usa el ultimo valor observado                     |
| `mean`                     | No          | —                   | Solo Java, media historica                                   |
| `perc95`                   | No          | —                   | Solo Java, percentil 95                                      |
| `percX` (param)            | No          | —                   | Solo Java, percentil configurable                            |
| `simpleExpSmoothing`       | No/Posible  | —                   | Puede ser Java nativo                                        |
| `holtExpSmoothing`         | No/Posible  | —                   | Holt exponential smoothing                                   |
| `holtWintersExpSmoothing`  | No/Posible  | —                   | Holt-Winters con estacionalidad                              |
| `knn`                      | Si          | `sklearn`           | k-Nearest Neighbors, param: k (3-8 explorados)              |
| `autoArima`                | Si          | `pmdarima`          | Auto ARIMA, seleccion automatica de orden                    |
| `fbProphet`                | Si          | `prophet`           | Facebook Prophet; requiere tambien `pandas`, `numpy`        |
| `neuralProphet`            | Si          | `neuralprophet`     | Neural Prophet; requiere `torch`                             |
| `bollinger` (signal)       | Si          | `numpy`             | Bollinger Bands como procesado de senal pre-forecast         |
| `interpeaks` (signal)      | Si          | `numpy`/`scipy`     | Inter-peaks signal processing, alternativa al bollinger      |

> **jpy**: biblioteca Java-Python bridge que permite llamar codigo Python desde Java/CloudSim.
> El `hostSignalProcessing` se aplica ANTES del `hostForecastingTechnique` como preprocesado de senal.

---

## 4. Workloads con paths exactos

### PlanetLab

| Campo              | Valor                                          |
|--------------------|------------------------------------------------|
| `workloadTrace`    | `"planetlab/planetlab_20110303_100_mostDiff"`  |
| Path en disco      | `networkExperiments/workloads/planetlab/planetlab_20110303_100_mostDiff/` |
| Numero de VMs      | 100 (seleccion "most different" de la traza)   |
| Duracion traza     | 86400 s = 1 dia (datos de 2011-03-03)          |
| Fuente             | CloudSim default dataset, red global 1353 nodos, 717 ubicaciones, 48 paises |
| CPU median         | 24.0 ± 17.2 %                                  |
| CPU accumulated diff | 3996 ± 1312                                  |
| Caracteristica     | Alta variabilidad, cambios bruscos CPU          |

### Alibaba 2018

| Campo              | Valor                                                             |
|--------------------|-------------------------------------------------------------------|
| `workloadTrace`    | `"alibaba2018/alibaba2018_fixed_first_500_100_mostDiff"`         |
| Path en disco      | `networkExperiments/workloads/alibaba2018/alibaba2018_fixed_first_500_100_mostDiff/` |
| Numero de VMs      | 100 (seleccion de 500 VMs fijas, las 100 "most different")       |
| Duracion traza     | 86400 s = 1 dia (traza original: 8 dias, 4000 VMs)               |
| Fuente             | Alibaba Cluster Trace Program v2018 (cluster-trace-v2018)        |
| CPU median         | 32.2 ± 5.3 %                                                     |
| CPU accumulated diff | 1346 ± 132                                                     |
| Caracteristica     | Comportamiento estable, alta demanda CPU, VMs similares entre si  |

### Materna

| Campo              | Valor                                                              |
|--------------------|--------------------------------------------------------------------|
| `workloadTrace`    | `"materna/materna_trace1_valid_0_288_100_mostDiff"`               |
| Path en disco      | `networkExperiments/workloads/materna/materna_trace1_valid_0_288_100_mostDiff/` |
| Numero de VMs      | 100 (seleccion de trace1, pasos 0-288)                             |
| Duracion traza     | 86400 s = 1 dia (288 steps validados)                              |
| Fuente             | Materna IT holding, Nov 2015 - Feb 2016, 500 VMs por grupo        |
| CPU median         | 5.3 ± 6.4 %                                                       |
| CPU accumulated diff | 517 ± 630                                                        |
| Caracteristica     | Carga CPU muy baja y estable, escenario de procesamiento tranquilo |

### Microsoft Azure 2019

| Campo              | Valor                                                              |
|--------------------|--------------------------------------------------------------------|
| `workloadTrace`    | `"azure/azure_azure2019_traces_100_mostDiff"`                     |
| Path en disco      | `networkExperiments/workloads/azure/azure_azure2019_traces_100_mostDiff/` |
| Numero de VMs      | 100                                                                |
| Duracion traza     | 86400 s = 1 dia (traza original: 30 dias consecutivos)            |
| Fuente             | Azure Public Dataset 2019, ~2.7M instancias VM, 380M+ vcore-hours |
| CPU median         | 16.9 ± 15.6 %                                                     |
| CPU accumulated diff | 3148 ± 2342                                                      |
| Caracteristica     | Alta variabilidad acumulada en la mitad de las VMs, dificil de predecir |

---

## 5. Notebook de analisis

### Fichero

`networkExperiments/statistics_paper4.ipynb`

### Folder de generatedExperiments que carga

```python
folder = "paper4_test_plus_o"
currentFolder = baseFolder + folder
df = getStatisticsDataframe(currentFolder)
```

El `baseFolder` se define en `statisticsSource.ipynb` (importado con `%run statisticsSource.ipynb`).
Tipicamente apunta a `networkExperiments/generatedExperiments/`.

> Para los resultados finales del paper (30 seeds, 4 workloads) los pools relevantes son los
> `pool_paper4_test3_*_30_*_o` y `pool_paper4_test3_*_30_*_wbf_o` en `poolExperiments/`.

### Como ejecutarlo

```bash
# Desde el directorio networkExperiments/
jupyter notebook statistics_paper4.ipynb
```

Requiere tener instalado `statisticsSource.ipynb` en el mismo directorio y las dependencias: `pandas`, `numpy`, `plotly`, `datapane` (para exportar reportes).

### Salidas que genera

- Graficos interactivos Plotly (line surface, pareto 2D, barras estadisticas)
- Metricas principales analizadas:
  - `energy`, `energy+hosts+migrations` (energia total con arranques/apagados)
  - `slaOverall`, `sla`
  - `numberOfMigrations`, `numberOfDelayedMigrations`
  - `totalUsedHosts`, `numberOfHostShutdowns`
  - `timeElapsed`, `ratioES` (ratio energia-SLA)
  - `medianCPUDispersionOfActiveHosts`

---

## 6. Ground truth para reproducibilidad

Los siguientes valores son los resultados reportados en las Tablas 6-9 del paper. Los experimentos reproducidos deben aproximarse a estos valores (promedio de 30 seeds).

### Tabla 6 — PlanetLab Results

| Metrica                          | MU      | MMT     | RS      | MC      | WPSP    | WF      | WBF         |
|----------------------------------|---------|---------|---------|---------|---------|---------|-------------|
| Energy Consumption (kWh)         | 38.71   | 28.44   | 28.70   | 28.87   | 24.74   | 23.16   | **23.15**   |
| Total hosts used                 | 1719    | 1716    | 1732    | 1728    | **1669**| 1698    | 1749        |
| SLA Violation (%)                | 5.43    | 2.92    | 3.00    | 2.94    | 4.02    | 2.46    | **2.23**    |
| # of migrations                  | 1618    | 931     | 776     | 828     | 454     | 322     | **296**     |
| Ratio ME (x10^7)                 | 5.44    | 7.44    | 7.45    | 7.39    | 8.63    | 9.30    | **9.31**    |
| ESV                              | 210.27  | 84.15   | 85.79   | 85.23   | 99.77   | 56.33   | **53.84**   |
| Total allocated MIPS (x10^8)     | 20.95   | 21.47   | 21.42   | 21.48   | 21.24   | 21.46   | **21.60**   |
| Avg. Available MIPS/active host  | **1141**| 1038    | 1047    | 1040    | 941.82  | 960.47  | 1038        |
| Median CPU dispersion (%)        | 19.05   | 16.36   | 15.81   | 15.76   | 15.52   | **13.87**| 14.24      |
| VM communications (MB x10^5)     | 4.85    | 4.99    | 5.01    | 4.99    | **4.83**| 4.93    | 4.93        |
| RAM in BW (MB x10^5)             | 175.43  | 86.88   | 84.93   | 88.86   | 54.59   | 37.41   | **34.45**   |

### Tabla 7 — Alibaba Results

| Metrica                          | MU      | MMT     | RS      | MC      | WPSP    | WF          | WBF         |
|----------------------------------|---------|---------|---------|---------|---------|-------------|-------------|
| Energy Consumption (kWh)         | 32.69   | 30.31   | 30.69   | 30.58   | 27.08   | **26.47**   | 28.02       |
| Total used hosts                 | 2088    | 2085    | 2103    | 2090    | 1977    | **1963**    | 2179        |
| SLA Violation (%)                | 2.15    | 1.87    | 1.81    | **1.77**| 5.17    | 5.14        | 3.02        |
| # of migrations                  | 787     | 770     | 627     | 640     | 392     | 350         | **330**     |
| Ratio ME (x10^7)                 | 7.95    | 8.55    | 8.49    | 8.56    | 9.32    | **9.49**    | 9.21        |
| ESV                              | 69.82   | 57.60   | 55.14   | **54.19**| 139.35 | 135.12      | 85.21       |
| Total allocated MIPS (x10^8)     | 25.90   | 25.99   | **26.00**| 25.33  | 25.33   | 25.11       | 25.80       |
| Avg. Available MIPS/active host  | 962.56  | 943.55  | 954.98  | 941.92  | 877.65  | 866.93      | **1117**    |
| Median CPU dispersion (%)        | 10.21   | **9.60**| 9.75    | 9.63    | 11.82   | 10.72       | 11.99       |
| VM communications (MB x10^5)     | 5.68    | 5.57    | 5.66    | 5.61    | 5.38    | **5.38**    | 5.77        |
| RAM in BW (MB x10^5)             | 86.14   | 66.95   | 68.19   | 66.39   | 46.88   | 42.58       | **40.45**   |

### Tabla 8 — Materna Results

| Metrica                          | MU      | MMT     | RS      | MC      | WPSP    | WF          | WBF         |
|----------------------------------|---------|---------|---------|---------|---------|-------------|-------------|
| Energy Consumption (kWh)         | 33.16   | 27.09   | 28.14   | 27.76   | 24.23   | **24.17**   | 25.13       |
| Total used hosts                 | 1642    | 1654    | 1669    | 1651    | **1621**| 1722        | 1968        |
| SLA Violation (%)                | 4.42    | 3.91    | 3.87    | 4.00    | 4.78    | 3.48        | **2.41**    |
| # of migrations                  | 1202    | 840     | 758     | 736     | 454     | 371         | **320**     |
| Ratio ME (x10^7)                 | 6.43    | 7.94    | 7.64    | 7.83    | 8.78    | **9.00**    | 8.68        |
| ESV                              | 148.35  | 103.10  | 110.03  | 109.95  | 112.77  | 84.55       | **60.68**   |
| Total allocated MIPS (x10^8)     | 21.45   | 21.60   | 21.60   | 21.59   | 21.29   | 21.63       | **21.95**   |
| Avg. Available MIPS/active host  | 840.10  | 831.02  | 862.33  | 860.64  | 797.27  | 977.05      | **1434**    |
| Median CPU dispersion (%)        | 14.91   | 14.16   | 14.18   | 14.56   | **13.81**| 14.54      | 16.82       |
| VM communications (MB x10^5)     | 5.54    | 5.69    | 5.68    | 5.78    | **5.53**| 5.59        | 5.78        |
| RAM in BW (MB x10^5)             | 130.29  | 76.46   | 83.92   | 79.13   | 52.12   | 44.84       | **36.94**   |

### Tabla 9 — Azure Results

| Metrica                          | MU      | MMT     | RS      | MC      | WPSP    | WF          | WBF         |
|----------------------------------|---------|---------|---------|---------|---------|-------------|-------------|
| Energy Consumption (kWh)         | 30.82   | 25.78   | 26.70   | 26.62   | 23.76   | **23.43**   | 24.59       |
| Total hosts used                 | **1725**| 1734    | 1740    | 1728    | 1734    | 1782        | 1964        |
| SLA Violation (%)                | 2.07    | 1.75    | 1.73    | 1.75    | 2.36    | 2.26        | **1.63**    |
| # of migrations                  | 926     | 599     | 561     | 582     | 340     | 294         | **259**     |
| Ratio ME (x10^7)                 | 7.20    | 8.72    | 8.47    | 8.38    | 9.36    | **9.55**    | 9.10        |
| ESV                              | 65.13   | 44.97   | 45.54   | 47.03   | 55.78   | 51.98       | **39.50**   |
| Total allocated MIPS (x10^8)     | 22.28   | 22.28   | 22.31   | **22.32**| 22.12  | 22.18       | 22.26       |
| Avg. Available MIPS/active host  | 870.22  | 879.59  | 911.68  | 883.05  | 851.79  | 865.50      | **1283**    |
| Median CPU dispersion (%)        | 13.80   | 13.61   | 13.96   | 13.86   | **13.08**| 13.18      | 16.12       |
| VM communications (MB x10^5)     | **5.63**| 5.82    | 5.76    | 5.75    | **5.63**| 5.73        | 5.81        |
| RAM in BW (MB x10^5)             | 100.85  | 55.69   | 62.23   | 64.53   | 39.16   | 33.48       | **29.89**   |

> **IMPORTANTE**: Estos valores son el ground truth. Los experimentos reproducidos deben aproximarse a ellos con variacion estadistica aceptable dentro del intervalo de confianza de 30 seeds.

### Resumen comparativo WBF (propuesta principal)

| Workload  | Energy (kWh) | SLA (%)    | Migrations | ESV        | RAM in BW (x10^5 MB) |
|-----------|--------------|------------|------------|------------|----------------------|
| PlanetLab | **23.15**    | **2.23**   | **296**    | **53.84**  | **34.45**            |
| Alibaba   | 28.02        | 3.02       | **330**    | 85.21      | **40.45**            |
| Materna   | 25.13        | **2.41**   | **320**    | **60.68**  | **36.94**            |
| Azure     | 24.59        | **1.63**   | **259**    | **39.50**  | **29.89**            |

---

## 7. Configuracion minima para smoke test

Config JSON minima que NO requiere jpy (sin Python), usando solo la tecnica `last` (Java nativo):

```json
{
    "name": ["paper4_smoke_test"],
    "experimentOutputFolder": ["paper4_smoke_test"],
    "allocationPolicy": ["custom"],
    "techniqueLoader": ["v3"],
    "selectionPolicy": ["psp2"],
    "selectionMode": ["first"],
    "vmMigrationPolicy": ["ac"],
    "vmOptimizerPolicy": ["future"],
    "hostOverSaturationPolicy": ["mad"],
    "hostUnderUtilisationPolicy": ["def"],

    "hostSignalProcessing": [["none"]],
    "hostForecastingTechnique": [["last"]],
    "hostForecastingResume": ["mean"],

    "vmSignalProcessingAccurate": [["none"]],
    "vmForecastingTechniqueAccurate": [["last"]],
    "vmForecastingResumeAccurate": ["mean"],

    "vmSignalProcessingBasic": [["none"]],
    "vmForecastingTechniqueBasic": [["last"]],
    "vmForecastingResumeBasic": ["mean"],

    "signalProcessing": [["none"]],
    "forecastingTechnique": [["last"]],
    "limitAdjustment": [["none"]],

    "topology": ["fatTreeTopology_k-2_g-2_s-2_hs-2_h-16"],
    "hosts": ["testHostsOneCore"],
    "hostsDistribution": [[1, 1]],
    "vms": ["vms4"],
    "vmsDistribution": [[1, 2, 3, 4, 5]],

    "workload": ["path"],
    "workloadTrace": ["planetlab/planetlab_20110303_100_mostDiff"],

    "dynamicResources": [["CPU", "BW", "RAM"]],
    "numCloudlets": [100],
    "randomSeed": [0],
    "migrationInterval": [6],
    "simulationTimeLimit": [86400.0],
    "utilizationThreshold": [1.0],
    "hostAllocationUtilization": [0.4],

    "internalClusterRate": [0.05],
    "externalClusterRate": [0.01],
    "defaultHistoryLength": [30],
    "forecastingHistoryLength": [30],
    "techniquesConfiguration": [{"pearson": 0.45}],
    "tunningValue": [0.65],
    "isTunning": [true],

    "interactions": [["fnss3000_0_20", "fnss3000_20_60", "fnss3000_60_95"]],
    "interactionsDistribution": [[5, 3, 2]],
    "network": [true],
    "overrideLinkWeight": [true],
    "logicLinkWeight": [10],
    "defaultWeight": [100],
    "defaultWeightInterconnected": [1000],

    "mipsStatsInterpolation": [false],
    "parameter": ["1.0"],
    "dataStartStep": [0],
    "onlyInitialHosts": [false],
    "outputFullTrace": [false],
    "outputCSVTrace": [false],
    "outputGraphTrace": [false],
    "outputToFile": [false],
    "enableOutput": [false],
    "printer": [false],
    "logOutputFolder": ["outputLog"]
}
```

### Diferencias con el experimento completo

| Aspecto          | Smoke test        | Experimento Paper 4 completo       |
|------------------|-------------------|------------------------------------|
| Workloads        | Solo PlanetLab    | 4 workloads                        |
| Seeds            | 1 (seed=0)        | 30 (seeds 0-29)                    |
| Tecnicas         | Solo `last`       | 7 tecnicas (MU, MMT, RS, MC, WPSP, WF, WBF) |
| jpy requerido    | No                | Si (para WF y WBF)                 |
| Tiempo estimado  | ~5-15 min         | ~días (30 seeds x 7 tecnicas x 4 workloads) |

### Resultado esperado del smoke test

Ejecutando con `selectionPolicy=psp2`, `hostForecastingTechnique=last`, seed=0, PlanetLab, debe producir valores proximos a los de la columna WPSP de la Tabla 6:
- Energy: ~24.74 kWh
- SLA: ~4.02%
- Migrations: ~454

---

## Notas de reproducibilidad

1. **Inicializacion aleatoria**: Las VMs se asignan aleatoriamente a los hosts al inicio (controlado por `randomSeed`). Con 30 seeds se obtiene diversidad estadistica suficiente.

2. **Modelo energetico extendido**: El paper NO usa el modelo energetico por defecto de CloudSim. Incluye: arranque de host (43020 J), apagado (5560 J), migracion con topologia (`E_mig+`), y comunicaciones VM.

3. **Demanda objetivo**: Los workloads se escalan para que demanden aproximadamente 2.67 millones de MIPS (50% de la capacidad total del datacenter: 16 hosts x media ~333 MIPS efectivos).

4. **Sanitizacion de trazas**: Las trazas fueron preprocesadas: se eliminaron VMs sin suficiente informacion CPU, se descartaron outliers (VMs casi vacias), y se rellenaron huecos con datos del mismo workload.

5. **Tecnica de deteccion de saturacion**: MAD (Median Absolute Deviation) — campo `hostOverSaturationPolicy: "mad"`.

6. **Politica de subutilizacion**: `def` — apaga hosts con carga muy baja redistribuyendo sus VMs.
