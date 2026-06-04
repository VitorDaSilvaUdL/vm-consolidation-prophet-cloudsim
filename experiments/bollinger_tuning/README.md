# Experimento: Bollinger tuning

## Objetivo

Encontrar los parámetros de Bollinger Bands (window N, amplitud α) que usó Sergi en el paper. El config del paper deja el parámetro activo como `[none]` y los reales en un comentario `___hostSignalProcessing` con candidatos `[4, 1.5]`. El texto del PDF menciona N=20, α=2.

Mi WBF con `bollinger(5, 0.5)` migra **más** que Sergi (materna 418 vs 320). Un α mayor ensancha las bandas → filtra más migraciones → menos migraciones. Hay que encontrar el α/N que reproduce los valores de Sergi.

## Referencia (output real de Sergi, # migraciones WBF)

| Workload | Sergi WBF mig | Mío con (5,0.5) |
|----------|--------------|-----------------|
| PlanetLab | 296 | 300 ✓ ya cuadra |
| Alibaba | 330 | 369 |
| Materna | 320 | 418 |
| Azure | 259 | 322 |

## Diseño

Barrido sobre **materna** (mayor gap), `vms4_materna`, fbProphet + 5 semillas:
- `bollinger(4, 1.5)` — candidato del comentario del config
- `bollinger(5, 2.0)`
- `bollinger(20, 2.0)` — valores del texto PDF
- `bollinger(4, 2.0)`

Config: `networkExperiments/testbed/exp_bollinger_search.json`

## Criterio

El parámetro cuyo WBF en materna se acerque más a **320 migraciones** (y SLA ~2.4%) es el de Sergi. Luego se aplica a los 4 workloads (bollinger_full_rerun).

## Ejecución

```powershell
cd project_minimized
docker-compose run --rm metacloudsim bash -c "java -jar /workspace/networkExperiments/metacloud.jar testbed exp_bollinger_search && java -jar /workspace/networkExperiments/metacloud.jar folder exp_bollinger_search"
```

## Resultados

_(se rellenan tras la ejecución — ver RESULTS.md)_
