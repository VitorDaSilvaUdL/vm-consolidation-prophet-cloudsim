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

## Quick start (clone → build → run)

Only **Docker** and **Git LFS** are required (no local Java/Python). Everything else —
simulator (`metacloud.jar`), configs, workloads and forecasting code — is in the repo.

```bash
git lfs install
git clone https://github.com/VitorDaSilvaUdL/vm-consolidation-prophet-cloudsim.git
cd vm-consolidation-prophet-cloudsim
docker compose build                         # build the image (~10 min, first time)
docker compose run --rm sim                  # run PlanetLab (WBF + Prophet)
docker compose up jupyter                    # analysis at http://localhost:8888
```

Run any experiment by name (file in `testbed/` without `.json`):

**Linux / macOS**
```bash
docker run --rm -v "$PWD":/workspace -w /workspace metacloudsim \
  java -jar metacloud.jar testbed paper4_full_alibaba_prophet
```
**Windows (PowerShell)**
```powershell
docker run --rm -v "${PWD}:/workspace" -w /workspace metacloudsim `
  java -jar metacloud.jar testbed paper4_full_alibaba_prophet
```

➡ **Full step-by-step for every experiment: [REPRODUCE.md](REPRODUCE.md)** (Linux + Windows).

---

## Workloads (data)

The experiments use four public cloud workloads — **PlanetLab, Alibaba 2018, Materna, Microsoft
Azure 2019**. Small **100-VM processed subsets** (`*_100_mostDiff`, ~8 MB total) are **included**
under `workloads/` so everything reproduces from a single clone. Each dataset keeps its original
license — see **[workloads/DATA_LICENSES.md](workloads/DATA_LICENSES.md)** for sources, terms and
citations. The reference values (paper Tables 6–9) are in `results/reference/`.

---

## Repository structure

```
.
├── metacloud.jar             # the CloudSim-based simulator (Git LFS)
├── launcher.json             # paths used inside the container (baseFolder=/workspace)
├── pymodule/                 # Python forecasting (Prophet, Bollinger, ...) loaded via jpy
├── testbed/                  # experiment configs (paper4_full_*, exp_*)
├── workloads/                # 100-VM trace subsets + DATA_LICENSES.md
├── topologies/ hosts/ vms/   # network topology and host/VM definitions
├── interactions/             # VM-to-VM communication patterns
├── results/                  # run outputs (results/reference/ = paper Tables 6–9)
├── experiments/              # additional studies (NeuralProphet vs Prophet, Bollinger tuning)
├── scripts/                  # analysis helpers + container entrypoint
├── python/notebooks/         # analysis notebooks (tables and figures)
├── Dockerfile                # toolchain: Java 8 + Python 3.8 + Prophet + jpy
├── Dockerfile.neural         # variant with NeuralProphet (forecaster comparison)
├── docker-compose.yml        # services: sim + jupyter
└── REPRODUCE.md              # how to run each experiment (Linux + Windows)
```

---

## Documentation

| File | Description |
|------|-------------|
| [REPRODUCE.md](REPRODUCE.md) | How to run each experiment (Linux + Windows) |
| [experiments/README.md](experiments/README.md) | Additional studies (NeuralProphet vs Prophet, Bollinger tuning) |
| [results/reference/README.md](results/reference/README.md) | Paper Tables 6–9 (ground truth) |
| [workloads/DATA_LICENSES.md](workloads/DATA_LICENSES.md) | Workload sources, licences and citations |

---

## Reproducibility notes

- The classical baselines (MU/MMT/RS/MC/WPSP) reproduce the original output within < 5 %.
- Energy is **composite** (host energy + network-routing energy of migrations), as in the paper.
- The full 30-seed run over the four workloads has been executed (0 errors).

## Citation

If you use this code, please cite the paper above. Contact:
**Dr. Vitor Luiz da Silva Verbel** — vitor.dasilva@udl.cat
