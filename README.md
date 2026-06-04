# VM Consolidation with Facebook Prophet — Reproduction Package

Reproducible code, configurations and analysis for the paper:

> **Virtual Machine Consolidation in Cloud Computing based on Facebook Prophet Forecasting
> Neural-Network** — *Future Generation Computer Systems*.

**Authors:** Sergi Vila, Vitor Luiz da Silva, Rosa Ana Tomás, Francesc Giné, Fernando Guirado,
Josep L. Lérida, Fernando Cores — INSPIRES, Universitat de Lleida (UdL).

The proposed method, **WBF = WPSP + Bollinger Bands + Facebook Prophet**, performs proactive VM
consolidation: it forecasts host/VM load with Facebook Prophet, filters transient peaks with
Bollinger Bands, and selects which VMs to migrate with a Weighted Pearson Selection Policy (WPSP),
under an energy model that includes the network-routing cost of migrations.

This repository contains everything needed to **reproduce the experiments** (840 simulations =
4 workloads × 7 techniques × 30 seeds) in a self-contained Docker environment.

---

## Quick start (Docker)

The simulator needs Java 8 + Python 3.8 + Facebook Prophet, bridged by `jpy`. The Docker image
builds the whole toolchain (including `jpy` from source), so a single command reproduces an
experiment.

```bash
# 1) Build the image (Java 8 + Python 3.8 + Prophet + jpy)
docker build -t metacloudsim .

# 2) Run an experiment (output is written to ./results, outside the container)
docker compose run --rm metacloudsim

# 3) Analyse results / regenerate tables and figures
docker compose up jupyter      # then open http://localhost:8888
```

Windows (PowerShell) helper:

```powershell
.\scripts\docker_build_and_run.ps1 -Action build      # build image
.\scripts\docker_build_and_run.ps1 -Action smoke      # quick smoke test
.\scripts\docker_build_and_run.ps1 -Action jupyter    # analysis notebooks
```

---

## Workloads (data)

The experiments use four public cloud workloads — **PlanetLab, Alibaba 2018, Materna, Microsoft
Azure 2019**. Small **100-VM processed subsets** (`*_100_mostDiff`, ~8 MB total) are **included**
under `data/` so everything can be reproduced from a single clone. Each dataset keeps its original
license — see **[data/DATA_LICENSES.md](data/DATA_LICENSES.md)** for sources, terms and citations.
The reference values reproduced by this package (paper Tables 6–9) are in `results/reference/`.

---

## Repository structure

```
.
├── Dockerfile                # Java 8 + Python 3.8 + Prophet + jpy (ubuntu:20.04)
├── Dockerfile.neural         # variant with NeuralProphet (forecaster comparison)
├── docker-compose.yml        # services: metacloudsim + jupyter
├── configs/                  # launcher + paper4 experiment configs
├── scripts/                  # run + analysis scripts (PowerShell / Python / bash)
├── experiments/              # additional experiments (bollinger_tuning, neuralprophet)
├── python/notebooks/         # analysis notebooks (tables and figures)
├── data/                     # place workload traces here (see README_DATA.md)
├── results/reference/        # paper Tables 6–9 (ground truth)
└── docs/                     # audit, specs, reproducibility report
```

---

## Documentation

| File | Description |
|------|-------------|
| [docs/REPRODUCIBILITY_REPORT.md](docs/REPRODUCIBILITY_REPORT.md) | Reproducibility status and how-to |
| [docs/PAPER4_SPECS.md](docs/PAPER4_SPECS.md) | Exact experiment specification |
| [docs/CODE_AUDIT.md](docs/CODE_AUDIT.md) | Technical audit |
| [results/reference/README.md](results/reference/README.md) | Paper Tables 6–9 (ground truth) |
| [environment/java_python_versions.md](environment/java_python_versions.md) | Java 8 / Python 3.8 setup |

---

## Reproducibility notes

- The classical baselines (MU/MMT/RS/MC/WPSP) reproduce the original output within < 5 %.
- Energy is **composite** (host energy + network-routing energy of migrations), as in the paper.
- The full 30-seed run over the four workloads has been executed (0 errors).

## Citation

If you use this code, please cite the paper above. Contact:
**Dr. Vitor Luiz da Silva Verbel** — vitor.dasilva@udl.cat
