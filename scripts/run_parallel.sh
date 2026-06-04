#!/bin/bash
# Lanza N workers paralelos, uno por cada pool de particion (paper4_full_*_p*).
# Cada worker procesa SU pool (disjunto) => sin colision, resultados identicos.
#
# Corre DENTRO del container Docker (servicio runner-parallel).
# El dashboard (puerto 8080) agrupa las particiones _pN por workload.
#
# Uso:
#   bash run_parallel.sh
#
# Si se interrumpe, re-lanzarlo continua desde el pending/ de cada particion.

set -e
JAR=/workspace/networkExperiments/metacloud.jar
POOLDIR=/workspace/networkExperiments/poolExperiments

pools=$(ls -d "$POOLDIR"/paper4_full_*_p* 2>/dev/null | sed 's#.*/##')
if [ -z "$pools" ]; then
  echo "No hay pools de particion. Ejecuta primero gen + setup_parallel.sh"
  exit 1
fi

n=$(echo "$pools" | wc -l)
echo "==================================================================="
echo " Ejecucion PARALELA — $n workers"
echo " Monitoriza: http://localhost:8080"
echo "==================================================================="

# Recuperacion: experimentos que quedaron en running/ de una ejecucion previa
# interrumpida vuelven a pending/ (exec-pool solo drena pending/). Seguro aqui
# porque NO hay workers activos todavia.
recovered=0
for pool in $pools; do
  rdir="$POOLDIR/${pool}/running"
  if [ -d "$rdir" ]; then
    for f in "$rdir"/*.json; do
      [ -e "$f" ] || continue
      mv "$f" "$POOLDIR/${pool}/pending/"
      recovered=$((recovered+1))
    done
  fi
done
[ "$recovered" -gt 0 ] && echo "Recuperados $recovered experimentos de running/ -> pending/"

echo "$pools" | sed 's/^/  worker: /'
echo ""

pids=""
for pool in $pools; do
  # Cada worker en background, log propio
  log="/workspace/networkExperiments/poolExperiments/${pool}/worker.log"
  ( java -jar "$JAR" exec-pool "$pool" pending > "$log" 2>&1 ) &
  pids="$pids $!"
  echo ">>> worker $pool lanzado (PID $!, log: ${pool}/worker.log)"
  sleep 2   # escalonar arranques para no saturar I/O inicial
done

echo ""
echo "Esperando a que terminen los $n workers..."
wait $pids
echo ""
echo "==================================================================="
echo " Todos los workers terminaron. Resultados en networkExperiments/output/"
echo "==================================================================="
