#!/bin/bash
# Espera a que terminen los 840 experimentos del Paper 4 y suspende Windows.
# Corre en el HOST (Git bash), en background. Sondea cada 60s.
#
# Condiciones de parada:
#   - completado: completed+error >= 840
#   - estancado: 30 min sin progreso (worker muerto / sin pending activo)
#
# Al terminar: escribe RUN_SUMMARY.txt y suspende (SetSuspendState).

POOLDIR="/c/Users/PcVIP/Desktop/Proyecto Sergi/networkExperiments/poolExperiments"
SUMMARY="/c/Users/PcVIP/Desktop/Proyecto Sergi/RUN_SUMMARY.txt"
TARGET=840
prev=-1
stall=0

count() { ls "$POOLDIR"/paper4_full_*_p*/"$1"/*.json 2>/dev/null | wc -l; }

while true; do
  done=$(count completed)
  err=$(count error)
  run=$(count running)
  pend=$(count pending)
  settled=$((done + err))

  if [ "$settled" -ge "$TARGET" ]; then reason="completado"; break; fi

  if [ "$settled" -eq "$prev" ]; then stall=$((stall + 1)); else stall=0; fi
  prev=$settled
  if [ "$stall" -ge 30 ]; then reason="estancado (30 min sin progreso)"; break; fi

  sleep 60
done

{
  echo "================ Run Paper 4 — Resumen ================"
  echo "Fecha:   $(date)"
  echo "Motivo:  $reason"
  echo "completed=$done  error=$err  running=$run  pending=$pend  / $TARGET"
  echo ""
  echo "Resultados en: networkExperiments/output/paper4_full_*"
  echo "Siguiente: analisis Python (statistics_paper4.ipynb)"
  echo "======================================================="
} > "$SUMMARY"

echo "[suspend_when_done] $reason. Suspendiendo Windows..."
powershell.exe -NoProfile -Command "rundll32.exe powrprof.dll,SetSuspendState 0,1,0"
