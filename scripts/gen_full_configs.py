#!/usr/bin/env python3
"""
Genera los 8 testbed configs para la reproduccion completa del Paper 4.

Por cada workload (PlanetLab, Materna, Alibaba, Azure) crea 2 configs:
  - <wl>_static : MU, MMT, RS, MC, WPSP  (tecnica 'last', sin jpy/Prophet)  -> 5 x 30 seeds = 150
  - <wl>_prophet: WF, WBF                (fbProphet +/- Bollinger)            -> 2 x 30 seeds = 60

Total: 4 x (150 + 60) = 840 experimentos = Tablas 6-9 del paper.

Basado en la config validada networkExperiments/testbed/paper4_val_wbf.json
(vmOptimizerPolicy=future, techniqueLoader=v3) que reproduce las tendencias
del paper.

Uso (desde la raiz del proyecto o dentro de Docker):
    python3 gen_full_configs.py --testbed-dir networkExperiments/testbed
"""
import argparse
import json
import os

# trace + vms exactos por workload (Table 5 del paper).
# planetlab/alibaba: vms4 (CPU 500-2500). materna/azure: vms4_materna (CPU 2000-5000).
WORKLOADS = {
    "planetlab": ("planetlab/planetlab_20110303_100_mostDiff", "vms4"),
    "materna":   ("materna/materna_trace1_valid_0_288_100_mostDiff", "vms4_materna"),
    "alibaba":   ("alibaba2018/alibaba2018_fixed_first_500_100_mostDiff", "vms4"),
    "azure":     ("azure/azure_azure2019_traces_100_mostDiff", "vms4_materna"),
}

SEEDS = list(range(30))  # 30 semillas como el paper


def base_config(name, trace, vms="vms4"):
    """Campos comunes a static y prophet (de paper4_val_wbf.json validado)."""
    return {
        "override": [],
        "name": [name],
        "experimentOutputFolder": [name],
        "vmOptimizerPolicy": ["future"],
        "selectionMode": ["first"],
        "hostOverSaturationPolicy": ["mad"],
        "hostUnderUtilisationPolicy": ["def"],
        "vmMigrationPolicy": ["ac"],
        "allocationPolicy": ["custom"],
        "techniqueLoader": ["v3"],
        "dataSource": ["original"],
        "signalProcessing": [["none"]],
        "forecastingTechnique": [["last"]],
        "hostForecastingResume": ["mean"],
        "vmSignalProcessingAccurate": [["none"]],
        "vmForecastingTechniqueAccurate": [["last"]],
        "vmForecastingResumeAccurate": ["mean"],
        "vmSignalProcessingBasic": [["none"]],
        "vmForecastingTechniqueBasic": [["last"]],
        "vmForecastingResumeBasic": ["mean"],
        "limitAdjustment": [["none"]],
        "defaultHistoryLength": [30],
        "forecastingHistoryLength": [30],
        "techniquesConfiguration": [{"pearson": 0.45}],
        "topology": ["fatTreeTopology_k-2_g-2_s-2_hs-2_h-16"],
        "hosts": ["testHostsOneCore"],
        "hostsDistribution": [[1, 1]],
        "vms": [vms],
        "vmsDistribution": [[1, 2, 3, 4, 5]],
        "interactions": [["fnss3000_0_20", "fnss3000_20_60", "fnss3000_60_95"]],
        "interactionsDistribution": [[5, 3, 2]],
        "workload": ["path"],
        "workloadTrace": [trace],
        "dynamicResources": [["CPU", "BW", "RAM"]],
        "mipsStatsInterpolation": [False],
        "parameter": ["1.0"],
        "numCloudlets": [100],
        "utilizationThreshold": [1.0],
        "randomSeed": SEEDS,
        "migrationInterval": [6],
        "dataStartStep": [0],
        "simulationTimeLimit": [86400.0],
        "internalClusterRate": [0.05],
        "externalClusterRate": [0.01],
        "logOutputFolder": ["outputLog"],
        "printer": [False],
        "enableOutput": [False],
        "outputToFile": [True],
        "hostAllocationUtilization": [0.4],
        "onlyInitialHosts": [False],
        "outputFullTrace": [False],
        "outputCSVTrace": [False],
        "outputGraphTrace": [False],
        "overrideLinkWeight": [True],
        "logicLinkWeight": [10],
        "defaultWeight": [100],
        "defaultWeightInterconnected": [1000],
        "isTunning": [True],
        "tunningValue": [0.65],
        "network": [True],
        "adjustLoadRatio": [False],
        "minRatio": [0.55],
        "maxRatio": [0.65],
        "offsetRatio": [0.05],
    }


def static_config(wl, trace, vms):
    name = f"paper4_full_{wl}_static"
    cfg = base_config(name, trace, vms)
    # 5 tecnicas clasicas: MU, MMT, RS, MC, WPSP (todas con 'last')
    cfg["selectionPolicy"] = ["mu", "mmt", "rs", "mc", "psp2"]
    cfg["hostSignalProcessing"] = [["none"]]
    cfg["hostForecastingTechnique"] = [["last"]]
    return name, cfg


def prophet_config(wl, trace, vms):
    name = f"paper4_full_{wl}_prophet"
    cfg = base_config(name, trace, vms)
    # WF (psp2 + fbProphet + none) y WBF (psp2 + fbProphet + bollinger 5,0.5)
    cfg["selectionPolicy"] = ["psp2"]
    cfg["hostForecastingTechnique"] = [["fbProphet"]]
    cfg["hostSignalProcessing"] = [["none"], ["bollinger", 5, 0.5]]
    return name, cfg


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--testbed-dir",
                    default="networkExperiments/testbed",
                    help="carpeta testbed donde escribir los .json")
    args = ap.parse_args()

    os.makedirs(args.testbed_dir, exist_ok=True)
    written = []
    for wl, (trace, vms) in WORKLOADS.items():
        for builder in (static_config, prophet_config):
            name, cfg = builder(wl, trace, vms)
            path = os.path.join(args.testbed_dir, f"{name}.json")
            with open(path, "w") as f:
                json.dump(cfg, f, indent=2)
            n_tech = len(cfg["selectionPolicy"]) * len(cfg["hostSignalProcessing"])
            n_exp = n_tech * len(cfg["randomSeed"])
            written.append((name, n_exp))
            print(f"  {name}.json  ({n_exp} experimentos)")

    total = sum(n for _, n in written)
    print(f"\n{len(written)} configs generados. Total: {total} experimentos.")
    print("\nPools sugeridos (1 por workload, combina static+prophet):")
    for wl in WORKLOADS:
        print(f"  gen-pool paper4_full_{wl} paper4_full_{wl}_static paper4_full_{wl}_prophet")


if __name__ == "__main__":
    main()
