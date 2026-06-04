# Resultados de Referencia — Paper 4

Los resultados originales del paper estan en:
```
C:\Users\PcVIP\Desktop\Proyecto Sergi\networkExperiments\paper4_data\
```

Estos son el GROUND TRUTH con el que comparar cualquier re-ejecucion.

## Estructura de paper4_data/

```
paper4_data/
├── planetlab/
│   ├── planetlab_all.xlsx              # Tabla 6 del paper: todas las tecnicas
│   └── figures/                        # Graficas del paper
├── alibaba_wbf_final_without_wibf/
│   ├── alibaba_all.xlsx                # Tabla 7 del paper
│   └── figures/
├── materna_wbf_final_without_wibf/
│   ├── materna_all.xlsx                # Tabla 8 del paper
│   └── figures/
└── azure_wbf_final_without_wibf/
    ├── azure_all.xlsx                  # Tabla 9 del paper
    └── figures/
```

## Metricas reportadas en el paper

Las 4 metricas principales evaluadas:

| Metrica | Descripcion | Unidad | Mejor |
|---------|-------------|--------|-------|
| Energy | Consumo energetico total de la simulacion | kWh | Menor |
| SLA | Violaciones de SLA (Service Level Agreement) | % | Menor |
| Migrations | Numero de migraciones de VMs | # | Menor |
| ESV | Energy-SLA Value (metrica combinada) | adim | Menor |

## Tabla 6 — PlanetLab (resultados completos)

| Tecnica | Energy (kWh) | SLA (%) | Migrations | ESV |
|---------|-------------|---------|-----------|-----|
| MU | 38.71 | 5.43 | 1618 | 210.27 |
| MMT | 28.44 | 2.92 | 931 | 84.15 |
| RS | 28.70 | 3.00 | 776 | 85.79 |
| MC | 28.87 | 2.94 | 828 | 85.23 |
| WPSP | 24.74 | 4.02 | 454 | 99.77 |
| WF | 23.16 | 2.46 | 322 | 56.33 |
| **WBF** | **23.15** | **2.23** | **296** | **53.84** |

WBF = WF + Bollinger Bands signal processing -> mejor en 3 de 4 metricas

## Tabla 7 — Alibaba

| Tecnica | Energy (kWh) | SLA (%) | Migrations | ESV |
|---------|-------------|---------|-----------|-----|
| WF | 26.47 | 5.14 | 350 | 135.12 |
| **WBF** | 28.02 | **3.02** | **330** | **85.21** |

## Tabla 8 — Materna

| Tecnica | Energy (kWh) | SLA (%) | Migrations | ESV |
|---------|-------------|---------|-----------|-----|
| WF | 24.17 | 3.48 | 371 | 84.55 |
| **WBF** | 25.13 | **2.41** | **320** | **60.68** |

## Tabla 9 — Azure

| Tecnica | Energy (kWh) | SLA (%) | Migrations | ESV |
|---------|-------------|---------|-----------|-----|
| WF | 23.43 | 2.26 | 294 | 51.98 |
| **WBF** | 24.59 | **1.63** | **259** | **39.50** |

## Como comparar resultados de una nueva ejecucion

1. Ejecutar smoke test: `scripts/run_smoke_test.ps1`
2. Abrir `python/notebooks/statistics_paper4.ipynb`
3. En la primera celda, cambiar `baseFolder` a la ruta de `generatedExperiments/`
4. Ejecutar todas las celdas
5. Comparar tablas generadas con los valores de referencia arriba

Tolerancia aceptable: +/- 2% en todas las metricas (variabilidad por scheduler del OS).
