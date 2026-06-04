# Experimentos adicionales — Paper 4 (major review)

Cada subcarpeta es un experimento nuevo pedido por la revisión, con su propio README, config, resultados y conclusión. Todos se ejecutan con la misma infraestructura Docker + pools paralelos del proyecto.

| Experimento | Objetivo | Responde a |
|-------------|----------|-----------|
| [bollinger_tuning/](bollinger_tuning/) | Encontrar el parámetro Bollinger (window, α) que usó Sergi y cerrar el gap WBF | Rev 2: WF vs WBF marginal |
| [neuralprophet/](neuralprophet/) | Comparar NeuralProphet vs Facebook Prophet (WBF) | Rev 1: contribución pequeña |
| [bollinger_full_rerun/](bollinger_full_rerun/) | Re-ejecutar WF/WBF en los 4 workloads con el Bollinger correcto | cerrar reproducción exacta |

## Convención

- Config testbed: `networkExperiments/testbed/exp_<nombre>.json`
- Resultados: `networkExperiments/output/exp_<nombre>/`
- Análisis: `analyze_results.py` (energía compuesta = fórmula de Sergi)
- Comparación: contra el output real de Sergi (`paper4_data/`) y el PDF

## Reproducibilidad

```powershell
cd project_minimized
docker-compose run --rm metacloudsim bash -c "java -jar /workspace/networkExperiments/metacloud.jar testbed exp_<nombre> && java -jar /workspace/networkExperiments/metacloud.jar folder exp_<nombre>"
```
