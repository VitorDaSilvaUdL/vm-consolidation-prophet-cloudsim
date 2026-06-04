# Dashboard Web — Ejecución Paralela Paper 4

**Estado verificado**: 2026-06-03  
**Máquina de referencia**: i7-14700KF (20 cores físicos / 28 threads), 32 GB RAM

Este documento describe el sistema de ejecución paralela con dashboard web para reproducir
las 840 simulaciones del Paper 4 monitorizando el progreso en tiempo real.

---

## Índice

1. [Qué es](#1-qué-es)
2. [Quick start — 3 comandos](#2-quick-start--3-comandos)
3. [Cómo funciona](#3-cómo-funciona)
4. [Ajustar nivel de paralelismo](#4-ajustar-nivel-de-paralelismo)
5. [Monitorización](#5-monitorización)
6. [Control: parar y reanudar](#6-control-parar-y-reanudar)
7. [Por qué es seguro y reproducible](#7-por-qué-es-seguro-y-reproducible)
8. [Después de ejecutar](#8-después-de-ejecutar)
9. [Tiempos estimados](#9-tiempos-estimados)

---

## 1. Qué es

Dashboard web + ejecución paralela para reproducir las **840 simulaciones del Paper 4**
monitorizando el progreso en vivo.

**Los 840 experimentos** son:

```
4 workloads × (5 técnicas estáticas + 2 Prophet) × 30 seeds = 840
```

| Workload | Técnicas estáticas | Técnicas Prophet | Seeds | Subtotal |
|----------|--------------------|-----------------|-------|---------|
| PlanetLab | MU, MMT, RS, MC, WPSP | WF, WBF | 30 | 210 |
| Materna | MU, MMT, RS, MC, WPSP | WF, WBF | 30 | 210 |
| Alibaba | MU, MMT, RS, MC, WPSP | WF, WBF | 30 | 210 |
| Azure | MU, MMT, RS, MC, WPSP | WF, WBF | 30 | 210 |

**Componentes del sistema:**

| Fichero | Qué hace |
|---------|---------|
| `scripts/dashboard.py` | Servidor HTTP stdlib, auto-refresh 5 s, ETA, agrupa pools por workload |
| `scripts/gen_full_configs.py` | Genera 8 configs testbed (4 workloads × static/prophet) |
| `scripts/setup_parallel.sh <P>` | Particiona cada workload en P pools disjuntos |
| `scripts/run_parallel.sh` | Lanza 1 worker por pool de partición |
| `scripts/run_full_parallel.sh <P>` | Orquestador completo (gen + pool + split + run) |
| `scripts/run_full_experiments.sh` | Versión secuencial (1 worker) |

**Servicios docker-compose:**

| Servicio | Puerto | Función |
|---------|--------|---------|
| `dashboard` | 8080 | http://localhost:8080 — progreso en vivo |
| `runner` | — | Ejecución secuencial (1 worker) |
| `runner-parallel` | — | Ejecución paralela (por defecto P=2 → 8 workers) |

---

## 2. Quick start — 3 comandos

```powershell
cd "C:\Users\PcVIP\Desktop\Proyecto Sergi\project_minimized"

# 1. Arrancar dashboard (deja corriendo, abre http://localhost:8080)
docker-compose up -d dashboard

# 2. Lanzar ejecución paralela en background (8 workers con P=2)
docker-compose run --rm -d runner-parallel

# 3. Ver progreso en http://localhost:8080 (auto-refresh cada 5 s)
```

El dashboard muestra:
- Barra de progreso por workload (pending / running / completed / error)
- Badge "Nw" indicando cuántos workers atienden ese workload
- ETA estimado basado en el ritmo actual
- Página HTML pura — sin dependencias externas

---

## 3. Cómo funciona

### Flujo completo de `run_full_parallel.sh <P>`

```
┌────────────────────────────┐
│  gen_full_configs.py       │
│  Genera 8 configs testbed  │
│  (4 wl × static/prophet)  │
└────────────┬───────────────┘
             │
             ▼
┌────────────────────────────┐
│  metacloud.jar generate-pool│
│  Crea 4 pools:              │
│  paper4_full_planetlab      │
│  paper4_full_materna        │
│  paper4_full_alibaba        │
│  paper4_full_azure          │
└────────────┬───────────────┘
             │
             ▼
┌────────────────────────────────────────────────────┐
│  setup_parallel.sh <P>                             │
│  Particiona cada pool en P sub-pools DISJUNTOS     │
│  (mueve ficheros de pending/ en round-robin)        │
│                                                    │
│  paper4_full_planetlab_p0/pending/  ← N/P ficheros │
│  paper4_full_planetlab_p1/pending/  ← N/P ficheros │
│  paper4_full_materna_p0/pending/    ← N/P ficheros │
│  ...                                               │
│  (4 workloads × P particiones = 4P sub-pools)      │
└────────────┬───────────────────────────────────────┘
             │
             ▼
┌────────────────────────────────────────────────────┐
│  run_parallel.sh                                   │
│  1 worker por sub-pool                             │
│                                                    │
│  worker[0]: exec-pool paper4_full_planetlab_p0     │
│  worker[1]: exec-pool paper4_full_planetlab_p1     │
│  worker[2]: exec-pool paper4_full_materna_p0       │
│  ...                                               │
│  (4P workers en paralelo)                          │
└────────────┬───────────────────────────────────────┘
             │
             ▼
┌────────────────────────────────────────────────────┐
│  networkExperiments/output/                        │
│  paper4_full_<workload>_*/                         │
│  └── <experimento>_data.json                       │
└────────────────────────────────────────────────────┘
             ▲
             │ lee poolExperiments/paper4_full_*
┌────────────┴───────────┐
│  dashboard.py          │
│  http://localhost:8080 │
└────────────────────────┘
```

### Por qué particionado disjunto

El código de Sergi (`ExperimentPoolExecuter.moveFileToRunningFolder`) hace `System.exit(-1)`
si dos workers intentan reclamar el mismo fichero (colisión en `Files.move`).

**Solución**: cada worker tiene su propio `pending/` disjunto → cero colisiones,
cero errores de contención, comportamiento determinista.

---

## 4. Ajustar nivel de paralelismo

### Tabla RAM libre → P → workers

| RAM libre | P | Workers totales | RAM por worker (aprox) |
|-----------|---|-----------------|------------------------|
| ~8 GB | 1 | 4 | ~2 GB |
| ~13 GB | **2** (recomendado) | **8** | ~1.5 GB |
| ~20 GB | 3 | 12 | ~1.7 GB |
| ~28 GB | 4 | 16 | ~1.75 GB |

> La máquina actual (32 GB, ~13 GB libres en uso normal) funciona bien con **P=2 (8 workers)**.
> Si cierras Chrome/VS Code puedes liberar hasta ~20 GB y usar P=3.

### Cómo cambiar P

El servicio `runner-parallel` usa P=2 por defecto (`docker-compose.yml`).
Para usar otro valor, sobrescribe el comando al lanzar:

```powershell
# P=3 (12 workers) — requiere ~20 GB libres
docker-compose run --rm -d runner-parallel bash /workspace/scripts/run_full_parallel.sh 3

# P=4 (16 workers) — requiere ~28 GB libres
docker-compose run --rm -d runner-parallel bash /workspace/scripts/run_full_parallel.sh 4

# P=1 (4 workers, modo conservador)
docker-compose run --rm -d runner-parallel bash /workspace/scripts/run_full_parallel.sh 1
```

---

## 5. Monitorización

### Dashboard web (recomendado)

```
http://localhost:8080
```

Auto-refresh cada 5 segundos. Muestra por workload:
- Pending / Running / Completed / Error
- Porcentaje de avance y barra visual
- Badge "Nw" = N workers activos en ese workload
- ETA estimado (basado en ritmo de últimos minutos)

### Por terminal — contar completados

```powershell
# Total completados (todos los workloads)
(Get-ChildItem -Path "..\networkExperiments\poolExperiments\paper4_full_*\completed" -Filter "*.json" -Recurse -ErrorAction SilentlyContinue).Count

# Por workload
foreach ($wl in @("planetlab","materna","alibaba","azure")) {
    $n = (Get-ChildItem "..\networkExperiments\poolExperiments\paper4_full_${wl}*\completed" -Filter "*.json" -Recurse -ErrorAction SilentlyContinue).Count
    Write-Host "${wl}: $n / 210"
}
```

### Logs por worker

Cada sub-pool genera su propio log:

```
networkExperiments/poolExperiments/paper4_full_<workload>_p<N>/worker.log
```

```powershell
# Ver log de un worker concreto
Get-Content "..\networkExperiments\poolExperiments\paper4_full_planetlab_p0\worker.log" -Tail 20
```

---

## 6. Control: parar y reanudar

### Parar

```powershell
# Opción A: parar todos los servicios docker-compose
docker-compose stop

# Opción B: parar solo el runner paralelo
docker stop $(docker ps -q --filter "ancestor=project_minimized-runner-parallel")

# Opción C: por nombre de container (ver nombre con docker ps)
docker stop <nombre_container>
```

### Reanudar

```powershell
# Simplemente relanzar — continúa desde pending/ automáticamente
docker-compose run --rm -d runner-parallel
```

**El sistema es resiliente**: los experimentos que ya estaban en `completed/` no se repiten.
Los que estaban en `running/` cuando se paró quedarán en `running/` — moverlos a `pending/`
si se quiere re-ejecutarlos:

```powershell
# Recuperar experimentos que quedaron "running" tras un crash
Get-ChildItem "..\networkExperiments\poolExperiments\paper4_full_*\running" -Filter "*.json" |
    ForEach-Object { Move-Item $_.FullName (Join-Path $_.DirectoryName.Replace("\running","\pending") $_.Name) }
```

---

## 7. Por qué es seguro y reproducible

### Sin colisiones (particionado disjunto)

Cada worker tiene su propio `pending/` con ficheros únicos. No hay solapamiento entre workers.
El `System.exit(-1)` de `ExperimentPoolExecuter.moveFileToRunningFolder` nunca se dispara.

### Resultados idénticos a los de Sergi (randomSeed fijo)

Cada experimento JSON incluye `randomSeed` con valor fijo. El simulador es determinista:
los mismos parámetros + misma semilla = mismo resultado, independientemente de cuántos
workers haya corriendo en paralelo.

**Verificado**: 8 workers, 0 errores, resultados consistentes con la ejecución secuencial.

### Resiliente a crashes (modelo pool)

El modelo `pending/running/completed/error` garantiza que:
- Un experimento completado nunca se re-ejecuta
- Un crash deja el experimento en `running/` (recuperable)
- Se puede reanudar en cualquier momento sin perder trabajo

---

## 8. Después de ejecutar

### Dónde están los resultados

```
networkExperiments/output/
├── paper4_full_planetlab_*/
│   └── <experimento>_data.json
├── paper4_full_materna_*/
├── paper4_full_alibaba_*/
└── paper4_full_azure_*/
```

### Siguiente paso: análisis para las Tablas 6-9

```powershell
# Lanzar Jupyter
docker-compose up -d jupyter
# Abrir http://localhost:8888
```

En Jupyter, abrir `statistics_paper4.ipynb` y apuntar `baseFolder` a los resultados nuevos:

```python
baseFolder = '/workspace/networkExperiments/output/'
folder = "paper4_full_planetlab_p0"   # o el pool correspondiente
currentFolder = baseFolder + folder
df = getStatisticsDataframe(currentFolder)
```

Los resultados deben coincidir con las Tablas 6-9 del paper (promedio de 30 seeds).

---

## 9. Tiempos estimados

### Velocidad por tipo de experimento

| Tipo | Técnicas | JAR | Tiempo/experimento |
|------|----------|-----|-------------------|
| Estático | MU, MMT, RS, MC, WPSP | netcloud / metacloud | 10–60 s |
| Prophet | WF, WBF | metacloud (jpy) | 2–5 min |

### ETA total según paralelismo

La tabla siguiente asume: 600 experimentos estáticos (~30 s/exp promedio) y
240 experimentos Prophet (~3 min/exp). Tiempo total secuencial estimado: ~600×0.5 + 240×3 = ~1020 min ≈ 17 h.
Con P workers, el tiempo se divide aproximadamente entre P (cuello de botella = workers Prophet).

| P | Workers | ETA aproximado | Requisito RAM |
|---|---------|----------------|---------------|
| 1 | 4 | 12–20 h | ~8 GB libres |
| **2** | **8** | **6–10 h** | **~13 GB libres** |
| 3 | 12 | 4–7 h | ~20 GB libres |
| 4 | 16 | 3–5 h | ~28 GB libres |

> Los rangos son amplios porque el tiempo de Prophet depende del workload (longitud de la
> serie temporal) y la carga de CPU. PlanetLab tiende a ser más rápido que Alibaba/Azure.
> Monitorizar con el dashboard para ver el ritmo real y recalibrar.

> **GPU no aplica**: fbProphet usa Stan (CPU-only). La paralelización se basa en cores,
> no en GPU. Los 20 cores físicos del i7-14700KF son más que suficientes para 8–12 workers.
