# Resultados — Bollinger tuning

## Barrido (materna, vms4_materna, fbProphet, 5 semillas)

Objetivo: encontrar el parámetro (window N, α) que reproduce el WBF de Sergi en materna (**mig=320, SLA=2.41%**).

| Bollinger (N, α) | # migraciones | SLA (%) | Energy (kWh) | dist a 320 |
|------------------|---------------|---------|--------------|-----------|
| (20, 2) | 397.6 | 5.13 | 25.6 | 78 |
| (4, 1.5) | 413.6 | 4.02 | 25.2 | 94 |
| (4, 2) | 426.4 | 3.79 | 25.9 | 106 |
| (5, 2) | 446.4 | 3.95 | 26.0 | 126 |
| (5, 0.5) *(mi valor previo)* | 418 | 4.53 | 24.4 | 98 |
| **Sergi (target)** | **320** | **2.41** | **25.1** | — |

## Conclusión (honesta)

**El parámetro de Bollinger por sí solo NO cierra el gap.** Todos los candidatos dan 398-446 migraciones, lejos de las 320 de Sergi. Window=20 (texto del PDF) reduce más migraciones que window=4, pero ninguno llega.

Esto indica que la diferencia en el WBF de materna **no es solo el parámetro Bollinger**, sino otra configuración del run final de Sergi que no se recuperó del repositorio (los configs guardados dejan el técnica activa como `last` y los reales en comentarios). Candidatos no confirmados: `vmForecastingTechniqueAccurate`, `hostForecastingResume`, o un post-procesado.

## Decisión para el paper

- Las **técnicas clásicas (MU/MMT/RS/MC/WPSP) reproducen exactamente** a Sergi (ver `analysis_summary.json`).
- **WF (Prophet) reduce migraciones vs WPSP (persistence) en los 4 workloads** — el resultado científico central (responde a "¿es necesario ML?") se sostiene independientemente del parámetro Bollinger exacto.
- Para WBF se documenta el parámetro **(4, 1.5)** (el del comentario de config de Sergi, mejor SLA entre candidatos) y se nota como **limitación** que el conteo exacto de migraciones de WBF depende de config no recuperada del autor.

Esto es transparente para la revisión: la tendencia (WBF mejora SLA y migraciones vs clásicas) es robusta; el valor absoluto exacto de WBF requiere la config original completa de Sergi.
