# Experimento: Facebook Prophet vs NeuralProphet

## Objetivo

Sergi dudaba en el borrador (nota REVISAR, en catalán) si **NeuralProphet** sería mejor que **Facebook Prophet** como forecaster, porque NeuralProphet usa una deep-NN que considera el comportamiento local/reciente. Lo medimos **directamente** en nuestro simulador.

## Por qué importa

- Responde la duda del autor sobre el forecaster.
- Justifica empíricamente la elección (Revisor 1: "¿por qué Prophet?").

## Diseño

Misma config WBF en **PlanetLab** (workload variable, donde el forecaster importa), cambiando solo `hostForecastingTechnique` a `neuralProphet`:
- WF-NP = psp2 + neuralProphet + none
- WBF-NP = psp2 + neuralProphet + bollinger(5,0.5)
- 5 semillas

Config: `networkExperiments/testbed/exp_neuralprophet.json`
Imagen Docker: `metacloudsim-neural` (Dockerfile.neural: torch 1.6.0 + neuralprophet 0.2.7)

Ejecución:
```powershell
docker build -f project_minimized/Dockerfile.neural -t metacloudsim-neural project_minimized
docker run --rm -v ".../networkExperiments:/workspace/networkExperiments" -w /workspace \
  -e LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libpython3.8.so.1.0 metacloudsim-neural \
  bash -c "java -jar .../metacloud.jar testbed exp_neuralprophet && java -jar .../metacloud.jar folder exp_neuralprophet"
```

## Resultados (PlanetLab, 5 semillas)

| Técnica | Forecaster | # migraciones | SLA (%) | Energy (kWh) |
|---------|-----------|---------------|---------|--------------|
| WF | **Facebook Prophet** | **281** | **4.44** | **25.5** |
| WF | NeuralProphet | 353 | 6.00 | 26.7 |
| WBF | **Facebook Prophet** | **300** | **3.57** | **26.4** |
| WBF | NeuralProphet | 332 | 4.08 | 27.3 |

## Conclusión

**Facebook Prophet supera a NeuralProphet en las 3 métricas** (migraciones, SLA, energía), tanto en WF como en WBF, sobre PlanetLab.

Posibles razones:
1. NeuralProphet necesita más datos para entrenar bien; con ventanas cortas (30 pasos) el `lr_range_test` falla (warnings observados) y usa lr por defecto → ajuste subóptimo.
2. Facebook Prophet es más robusto con pocos datos y missing values, ideal para las ventanas cortas de decisión de migración.

**Para el paper:** esto **justifica empíricamente** la elección de Facebook Prophet sobre NeuralProphet (responde la duda del borrador y al Revisor 1). No es una elección arbitraria: FP rinde mejor en la tarea real con las ventanas de datos disponibles.

> Nota: comparación en 1 workload (PlanetLab, 5 semillas) como estudio dirigido. Ampliable a los 4 workloads si se requiere para el paper.
