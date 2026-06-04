#!/bin/bash
# Orquestador COMPLETO en paralelo: genera, particiona y ejecuta los 840
# experimentos del Paper 4 con N workers disjuntos (sin colision, determinista).
#
# Uso (dentro del container, servicio runner-parallel):
#   bash run_full_parallel.sh [P]
#     P = particiones por workload (workers totales = 4*P). Default 2 => 8 workers.
#
# Recomendacion segun RAM libre (~1.5GB/worker):
#   13GB libre -> P=2 (8 workers)
#   20GB libre -> P=3 (12 workers)
#   28GB libre -> P=4 (16 workers)
#
# Resiliente: re-lanzar continua desde pending/ de cada particion.
# Monitoriza: http://localhost:8080

set -e
P="${1:-2}"
JAR=/workspace/networkExperiments/metacloud.jar
TESTBED=/workspace/networkExperiments/testbed
SCRIPTS=/workspace/scripts
WORKLOADS="planetlab materna alibaba azure"

echo "=== [1/4] Generando configs ==="
python3.8 "$SCRIPTS/gen_full_configs.py" --testbed-dir "$TESTBED" | tail -3

echo ""
echo "=== [2/4] Generando pools base (si no existen) ==="
for wl in $WORKLOADS; do
  pool="paper4_full_${wl}"
  pooldir="/workspace/networkExperiments/poolExperiments/${pool}"
  # Si ya hay particiones de este workload, saltar (ya particionado)
  if ls -d /workspace/networkExperiments/poolExperiments/paper4_full_${wl}_p* >/dev/null 2>&1; then
    echo "  $wl: ya particionado, se conserva el progreso"
    continue
  fi
  if [ -d "$pooldir/pending" ] || [ -d "$pooldir/completed" ]; then
    echo "  $wl: pool base ya existe"
  else
    java -jar "$JAR" gen-pool "$pool" "paper4_full_${wl}_static" "paper4_full_${wl}_prophet" 2>&1 | grep -E 'Pool generated' || true
  fi
done

echo ""
echo "=== [3/4] Particionando en pools disjuntos (P=$P) ==="
bash "$SCRIPTS/setup_parallel.sh" "$P"

echo ""
echo "=== [4/4] Lanzando workers paralelos ==="
bash "$SCRIPTS/run_parallel.sh"
