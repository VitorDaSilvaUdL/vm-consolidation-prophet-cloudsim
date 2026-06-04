#!/bin/bash
# Runner de la reproduccion completa del Paper 4 (840 experimentos).
# Corre DENTRO del container Docker (servicio runner).
#
# Flujo:
#   1. Genera los 8 testbed configs (4 workloads x static/prophet)
#   2. Crea 1 pool por workload (combina static+prophet)
#   3. Ejecuta cada pool secuencialmente con exec-pool (resiliente)
#
# El dashboard (servicio aparte, puerto 8080) muestra el progreso en vivo.
# Si el runner se interrumpe, re-lanzarlo continua desde pending/.

set -e

JAR=/workspace/networkExperiments/metacloud.jar
TESTBED=/workspace/networkExperiments/testbed
WORKLOADS="planetlab materna alibaba azure"

echo "==================================================================="
echo " Paper 4 — Reproduccion completa (4 workloads x 7 tecnicas x 30 seeds)"
echo "==================================================================="

# 1. Generar configs
echo ""
echo "[1/3] Generando testbed configs..."
python3.8 /workspace/scripts/gen_full_configs.py --testbed-dir "$TESTBED"

# 2. Generar pools (idempotente: gen-pool no duplica si ya existen pending)
echo ""
echo "[2/3] Generando pools..."
for wl in $WORKLOADS; do
  pool="paper4_full_${wl}"
  pooldir="/workspace/networkExperiments/poolExperiments/${pool}"
  # Solo generar si el pool no existe aun (evita regenerar y perder progreso)
  if [ -d "$pooldir/completed" ] && [ "$(ls -A "$pooldir/completed" 2>/dev/null)" ]; then
    echo "  ${pool}: ya tiene completados, no se regenera"
  else
    echo "  ${pool}: gen-pool ${wl}_static + ${wl}_prophet"
    java -jar "$JAR" gen-pool "$pool" "paper4_full_${wl}_static" "paper4_full_${wl}_prophet" 2>&1 | tail -2
  fi
done

# 3. Ejecutar cada pool
echo ""
echo "[3/3] Ejecutando pools (esto puede tardar horas)..."
echo "      Monitoriza en: http://localhost:8080"
for wl in $WORKLOADS; do
  pool="paper4_full_${wl}"
  echo ""
  echo ">>> exec-pool ${pool}  ($(date '+%H:%M:%S'))"
  java -jar "$JAR" exec-pool "$pool" pending 2>&1 | grep -vE '^slotNum|^[0-9]+\.[0-9]+$' | tail -5 || true
done

echo ""
echo "==================================================================="
echo " Ejecucion completa. Resultados en networkExperiments/output/"
echo " Siguiente: analisis Python (statistics_paper4.ipynb)"
echo "==================================================================="
