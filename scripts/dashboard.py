#!/usr/bin/env python3
"""
Dashboard web para monitorizar la ejecucion de experimentos del Paper 4.

Escanea poolExperiments/<pool>/{pending,running,completed,error} y muestra
una pagina HTML con auto-refresh, barras de progreso y ETA estimado.

Sin dependencias externas (solo stdlib). Pensado para correr dentro del
container Docker y exponerse en un puerto.

Uso:
    python3 dashboard.py --pools-dir /workspace/networkExperiments/poolExperiments \
                         --prefix paper4_full_ --port 8080

    # O monitorizar pools concretos:
    python3 dashboard.py --pools planetlab materna alibaba azure --port 8080

Abrir luego: http://localhost:8080
"""
import argparse
import os
import re
import time
from datetime import datetime, timedelta
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

STATES = ["pending", "running", "completed", "error"]

# Quita sufijo de particion (_p0, _p1, ...) para agrupar workers del mismo workload.
_PART_RE = re.compile(r"_p\d+$")


def group_key(pool_name):
    return _PART_RE.sub("", pool_name)

# Historico (timestamp, total_completed) para estimar ritmo y ETA.
_history = []
_start_time = time.time()


def count_state(pool_path, state):
    d = os.path.join(pool_path, state)
    if not os.path.isdir(d):
        return 0
    try:
        return sum(1 for n in os.listdir(d) if n.endswith(".json"))
    except OSError:
        return 0


def discover_pools(pools_dir, prefix, explicit):
    """Devuelve lista de (nombre_pool, ruta_absoluta)."""
    if explicit:
        result = []
        for name in explicit:
            p = os.path.join(pools_dir, name)
            if os.path.isdir(p):
                result.append((name, p))
        return result
    pools = []
    if not os.path.isdir(pools_dir):
        return pools
    for name in sorted(os.listdir(pools_dir)):
        p = os.path.join(pools_dir, name)
        if not os.path.isdir(p):
            continue
        if prefix and not name.startswith(prefix):
            continue
        # Solo carpetas que parezcan pools (tienen pending/ o completed/).
        if any(os.path.isdir(os.path.join(p, s)) for s in STATES):
            pools.append((name, p))
    return pools


def gather(pools, grouped=True):
    """Agrega counts. Si grouped, suma las particiones _pN del mismo workload."""
    totals = {s: 0 for s in STATES}
    groups = {}  # clave -> {counts, total, workers}
    order = []
    for name, path in pools:
        counts = {s: count_state(path, s) for s in STATES}
        for s in STATES:
            totals[s] += counts[s]
        key = group_key(name) if grouped else name
        if key not in groups:
            groups[key] = {"name": key, "counts": {s: 0 for s in STATES},
                           "total": 0, "workers": 0}
            order.append(key)
        g = groups[key]
        for s in STATES:
            g["counts"][s] += counts[s]
        g["total"] += sum(counts.values())
        g["workers"] += 1
    data = [groups[k] for k in order]
    return data, totals


def estimate_eta(total_completed, total_all):
    """ETA por ritmo de completados en la ventana reciente."""
    now = time.time()
    _history.append((now, total_completed))
    # Mantener ultimos ~30 min de muestras.
    cutoff = now - 1800
    while len(_history) > 2 and _history[0][0] < cutoff:
        _history.pop(0)
    remaining = total_all - total_completed
    if remaining <= 0:
        return "completado", 100.0
    if len(_history) < 2:
        return "calculando...", _pct(total_completed, total_all)
    t0, c0 = _history[0]
    dt = now - t0
    dc = total_completed - c0
    if dt <= 0 or dc <= 0:
        return "calculando...", _pct(total_completed, total_all)
    rate = dc / dt  # experimentos por segundo
    eta_sec = remaining / rate
    return _fmt_duration(eta_sec), _pct(total_completed, total_all)


def _pct(a, b):
    return (a / b * 100.0) if b else 0.0


def _fmt_duration(sec):
    td = timedelta(seconds=int(sec))
    days = td.days
    h, rem = divmod(td.seconds, 3600)
    m, _ = divmod(rem, 60)
    if days:
        return f"{days}d {h}h {m}m"
    if h:
        return f"{h}h {m}m"
    return f"{m}m"


def bar(pct, width=28):
    filled = int(round(pct / 100.0 * width))
    return "█" * filled + "░" * (width - filled)


def render_html(pools_dir, prefix, explicit):
    pools = discover_pools(pools_dir, prefix, explicit)
    data, totals = gather(pools)
    grand_total = sum(totals.values())
    completed = totals["completed"]
    eta, pct = estimate_eta(completed, grand_total)

    running = totals["running"]
    errors = totals["error"]
    if grand_total == 0:
        status_txt, status_cls = "sin pools", "idle"
    elif completed >= grand_total:
        status_txt, status_cls = "DONE", "done"
    elif running > 0:
        status_txt, status_cls = "running", "run"
    elif errors > 0 and (completed + errors) >= grand_total:
        status_txt, status_cls = "con errores", "err"
    else:
        status_txt, status_cls = "idle", "idle"

    rows = []
    for d in data:
        c = d["counts"]
        done = c["completed"]
        tot = d["total"]
        p = _pct(done, tot)
        if tot == 0:
            badge = '<span class="b idle">vacio</span>'
        elif done >= tot:
            badge = '<span class="b done">DONE</span>'
        elif c["running"] > 0:
            badge = f'<span class="b run">running {c["running"]}</span>'
        elif c["error"] > 0:
            badge = f'<span class="b err">err {c["error"]}</span>'
        else:
            badge = '<span class="b idle">pending</span>'
        wk = d.get("workers", 1)
        wk_txt = f'<span class="wk">{wk}w</span>' if wk > 1 else ""
        label = d['name'].replace("paper4_full_", "")
        rows.append(f"""
          <tr>
            <td class="nm">{label} {wk_txt}</td>
            <td class="barcell"><div class="bar"><div class="fill" style="width:{p:.1f}%"></div></div></td>
            <td class="cnt">{done}/{tot}</td>
            <td class="pct">{p:.1f}%</td>
            <td>{badge}</td>
          </tr>""")

    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    elapsed = _fmt_duration(time.time() - _start_time)

    return f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta http-equiv="refresh" content="5">
<title>Paper 4 — Experiment Progress</title>
<style>
  :root {{ color-scheme: dark; }}
  body {{ font-family: 'Segoe UI', system-ui, sans-serif; background:#0d1117; color:#e6edf3;
         margin:0; padding:24px; }}
  .wrap {{ max-width: 880px; margin:0 auto; }}
  h1 {{ font-size:20px; margin:0 0 4px; }}
  .sub {{ color:#8b949e; font-size:13px; margin-bottom:20px; }}
  .top {{ display:flex; gap:24px; align-items:center; background:#161b22; border:1px solid #30363d;
          border-radius:10px; padding:18px 22px; margin-bottom:20px; }}
  .big {{ font-size:34px; font-weight:700; }}
  .big small {{ font-size:15px; color:#8b949e; font-weight:400; }}
  .topbar {{ flex:1; }}
  .tbar {{ height:14px; background:#21262d; border-radius:7px; overflow:hidden; margin-top:8px; }}
  .tfill {{ height:100%; background:linear-gradient(90deg,#1f6feb,#2ea043); transition:width .5s; }}
  table {{ width:100%; border-collapse:collapse; background:#161b22; border:1px solid #30363d;
           border-radius:10px; overflow:hidden; }}
  td {{ padding:12px 14px; border-top:1px solid #21262d; font-size:14px; }}
  .nm {{ font-weight:600; width:180px; }}
  .barcell {{ width:300px; }}
  .bar {{ height:16px; background:#21262d; border-radius:8px; overflow:hidden; }}
  .fill {{ height:100%; background:linear-gradient(90deg,#1f6feb,#2ea043); transition:width .5s; }}
  .cnt {{ font-variant-numeric:tabular-nums; color:#c9d1d9; }}
  .pct {{ font-variant-numeric:tabular-nums; color:#8b949e; width:60px; }}
  .b {{ padding:3px 10px; border-radius:12px; font-size:12px; font-weight:600; }}
  .b.done {{ background:#1a7f37; color:#fff; }}
  .b.run {{ background:#1f6feb; color:#fff; }}
  .b.err {{ background:#a40e26; color:#fff; }}
  .b.idle {{ background:#30363d; color:#8b949e; }}
  .wk {{ background:#6e40c9; color:#fff; padding:1px 7px; border-radius:9px; font-size:11px; font-weight:600; }}
  .legend {{ margin-top:16px; color:#8b949e; font-size:13px; }}
  .pill {{ display:inline-block; padding:2px 10px; border-radius:10px; margin-right:8px;
           font-variant-numeric:tabular-nums; }}
  .foot {{ margin-top:14px; color:#6e7681; font-size:12px; }}
  .st {{ padding:4px 12px; border-radius:14px; font-weight:700; font-size:13px; }}
  .st.run {{ background:#1f6feb; }} .st.done {{ background:#1a7f37; }}
  .st.idle {{ background:#30363d; color:#8b949e; }} .st.err {{ background:#a40e26; }}
</style>
</head>
<body>
<div class="wrap">
  <h1>Paper 4 — Experiment Progress</h1>
  <div class="sub">Virtual Machine Consolidation based on Facebook Prophet · MetaCloudSim</div>

  <div class="top">
    <div>
      <div class="big">{completed}<small>/{grand_total}</small></div>
      <div class="sub" style="margin:0">{pct:.1f}% completado</div>
    </div>
    <div class="topbar">
      <div class="tbar"><div class="tfill" style="width:{pct:.1f}%"></div></div>
      <div class="sub" style="margin:6px 0 0">ETA ~{eta} · transcurrido {elapsed}</div>
    </div>
    <div><span class="st {status_cls}">{status_txt}</span></div>
  </div>

  <table>
    <tbody>
      {''.join(rows) if rows else '<tr><td colspan="5" style="text-align:center;color:#8b949e">No hay pools. Genera con gen-pool.</td></tr>'}
    </tbody>
  </table>

  <div class="legend">
    <span class="pill" style="background:#30363d">pending {totals['pending']}</span>
    <span class="pill" style="background:#1f6feb">running {totals['running']}</span>
    <span class="pill" style="background:#1a7f37">completed {totals['completed']}</span>
    <span class="pill" style="background:#a40e26">error {totals['error']}</span>
  </div>
  <div class="foot">Actualizado {now_str} · refresca cada 5s · dashboard.py</div>
</div>
</body>
</html>"""


class Handler(BaseHTTPRequestHandler):
    pools_dir = ""
    prefix = ""
    explicit = None

    def do_GET(self):
        if self.path not in ("/", "/index.html"):
            self.send_response(404)
            self.end_headers()
            return
        html = render_html(self.pools_dir, self.prefix, self.explicit)
        body = html.encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *a):
        pass  # silencioso


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pools-dir", default="/workspace/networkExperiments/poolExperiments")
    ap.add_argument("--prefix", default="paper4_full_",
                    help="solo pools cuyo nombre empieza por este prefijo")
    ap.add_argument("--pools", nargs="*", default=None,
                    help="lista explicita de pools (ignora --prefix)")
    ap.add_argument("--port", type=int, default=8080)
    args = ap.parse_args()

    Handler.pools_dir = args.pools_dir
    Handler.prefix = args.prefix
    Handler.explicit = args.pools

    srv = ThreadingHTTPServer(("0.0.0.0", args.port), Handler)
    print(f"[dashboard] sirviendo en http://0.0.0.0:{args.port}")
    print(f"[dashboard] pools-dir: {args.pools_dir}")
    print(f"[dashboard] prefijo: {args.prefix!r}  explicitos: {args.pools}")
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        print("\n[dashboard] detenido")


if __name__ == "__main__":
    main()
