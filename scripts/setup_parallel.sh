#!/bin/bash
# Particiona los experimentos en pools DISJUNTOS para ejecucion paralela segura.
#
# Por que disjuntos: exec-pool hace System.exit(-1) si dos workers reclaman el
# mismo fichero (Files.move colisiona). Solucion: cada worker tiene su propio
# pool (pending/ propio) => CERO colision => resultados identicos a Sergi
# (cada experimento es determinista por su randomSeed).
#
# Reparte los 210 experimentos de cada workload en P particiones round-robin:
#   paper4_full_<wl>  ->  paper4_full_<wl>_p0, _p1, ..., _p{P-1}
#
# Total workers = 4 workloads x P particiones.
#
# Uso:
#   bash setup_parallel.sh <P>          # P particiones por workload
#   bash setup_parallel.sh 2            # 8 pools (8 workers) — recomendado 13GB RAM libre
#   bash setup_parallel.sh 3            # 12 pools (12 workers) — si hay mas RAM

set -e
P="${1:-2}"
POOLDIR=/workspace/networkExperiments/poolExperiments
WORKLOADS="planetlab materna alibaba azure"

echo "Particionando en P=$P por workload ($((4*P)) pools/workers totales)..."

for wl in $WORKLOADS; do
  src="$POOLDIR/paper4_full_${wl}"
  if [ ! -d "$src/pending" ]; then
    echo "  AVISO: $src/pending no existe; ejecuta gen-pool antes. Saltando."
    continue
  fi
  # Crear particiones con estructura de pool completa
  for ((i=0; i<P; i++)); do
    part="$POOLDIR/paper4_full_${wl}_p${i}"
    # 5 carpetas: el jar (showFolderStats) requiere tambien 'cancelled' o lanza NPE
    mkdir -p "$part/pending" "$part/running" "$part/completed" "$part/error" "$part/cancelled"
  done
  # Repartir pending round-robin
  idx=0
  for f in "$src/pending"/*.json; do
    [ -e "$f" ] || continue
    target="$POOLDIR/paper4_full_${wl}_p$((idx % P))/pending/"
    mv "$f" "$target"
    idx=$((idx+1))
  done
  echo "  $wl: $idx experimentos repartidos en $P particiones"
  # Limpiar el pool origen (ya vacio de pending)
  rmdir "$src/pending" "$src/running" "$src/completed" "$src/error" 2>/dev/null || true
  rmdir "$src" 2>/dev/null || true
done

echo ""
echo "Particionado completo. Pools listos:"
ls -d "$POOLDIR"/paper4_full_*_p* 2>/dev/null | sed 's#.*/#  #'
