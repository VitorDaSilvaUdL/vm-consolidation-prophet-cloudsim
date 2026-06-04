#!/usr/bin/env python3
"""
run_analysis.py
===============
Analiza los resultados existentes de paper4_data/ sin necesidad de re-ejecutar simulaciones.
Genera un summary Markdown con las metricas principales y lista los ficheros disponibles.

Funciona con Python 3.8+ y solo requiere: pathlib (stdlib), json (stdlib), argparse (stdlib)
Para analisis completo, usar statistics_paper4.ipynb con pandas/openpyxl.

Uso:
    python run_analysis.py
    python run_analysis.py --data-dir ../networkExperiments/paper4_data --output results/analysis/
    python run_analysis.py --verbose
"""
import argparse
import sys
from pathlib import Path
import json
import os


def parse_args():
    parser = argparse.ArgumentParser(
        description='Analisis de resultados Paper 4 MetaCloudSim'
    )
    parser.add_argument(
        '--data-dir',
        default=None,
        help='Directorio con resultados paper4_data/. Si no se especifica, busca automaticamente.'
    )
    parser.add_argument(
        '--output',
        default=None,
        help='Directorio de salida para el summary. Default: results/analysis/ junto al script.'
    )
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Mostrar mas informacion'
    )
    return parser.parse_args()


def find_paper4_data(script_dir: Path) -> Path:
    """Busca paper4_data/ en ubicaciones esperadas."""
    candidates = [
        script_dir.parent.parent / "networkExperiments" / "paper4_data",
        script_dir.parent / "networkExperiments" / "paper4_data",
        Path("../networkExperiments/paper4_data"),
        Path("networkExperiments/paper4_data"),
    ]
    for c in candidates:
        if c.exists():
            return c.resolve()
    return None


def get_file_size_human(path: Path) -> str:
    """Retorna tamano legible."""
    size = path.stat().st_size
    if size > 1024 * 1024:
        return f"{size / (1024*1024):.1f} MB"
    elif size > 1024:
        return f"{size / 1024:.0f} KB"
    return f"{size} B"


def analyze_workload(wl_dir: Path, verbose: bool = False) -> dict:
    """Analiza un directorio de workload y retorna stats."""
    result = {
        "name": wl_dir.name,
        "xlsx_files": [],
        "json_files": [],
        "png_files": [],
        "total_size_mb": 0,
    }

    for f in sorted(wl_dir.rglob("*")):
        if f.is_file():
            result["total_size_mb"] += f.stat().st_size / (1024 * 1024)
            if f.suffix == ".xlsx":
                result["xlsx_files"].append({"name": f.name, "size": get_file_size_human(f)})
            elif f.suffix == ".json":
                result["json_files"].append({"name": f.name, "size": get_file_size_human(f)})
            elif f.suffix in (".png", ".jpg", ".svg"):
                result["png_files"].append({"name": f.name, "size": get_file_size_human(f)})

    return result


def main():
    args = parse_args()
    script_dir = Path(__file__).parent.resolve()

    # Resolver data_dir
    if args.data_dir:
        data_dir = Path(args.data_dir).resolve()
    else:
        data_dir = find_paper4_data(script_dir)
        if data_dir is None:
            print("ERROR: No se encontro paper4_data/ automaticamente.")
            print("Especifica la ruta con: --data-dir <path>")
            print("Ejemplo: python run_analysis.py --data-dir C:/Users/PcVIP/Desktop/Proyecto Sergi/networkExperiments/paper4_data")
            sys.exit(1)

    if not data_dir.exists():
        print(f"ERROR: {data_dir} no existe.")
        sys.exit(1)

    # Resolver output_dir
    if args.output:
        output_dir = Path(args.output).resolve()
    else:
        output_dir = script_dir.parent / "results" / "analysis"

    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Analizando: {data_dir}")
    print(f"Output: {output_dir}")
    print()

    # Listar workloads (excluir carpetas con ' - copia')
    workloads = sorted([
        d for d in data_dir.iterdir()
        if d.is_dir() and " - copia" not in d.name
    ])

    if not workloads:
        print(f"ADVERTENCIA: No se encontraron subdirectorios en {data_dir}")
    else:
        print(f"Workloads encontrados: {[w.name for w in workloads]}")
        print()

    # Analizar cada workload
    all_stats = []
    for wl in workloads:
        stats = analyze_workload(wl, args.verbose)
        all_stats.append(stats)
        print(f"  {stats['name']}: "
              f"{len(stats['xlsx_files'])} xlsx, "
              f"{len(stats['json_files'])} json, "
              f"{len(stats['png_files'])} imagenes, "
              f"{stats['total_size_mb']:.1f} MB")

    # Generar summary Markdown
    lines = [
        "# Summary de resultados disponibles — Paper 4\n\n",
        f"**Directorio analizado**: `{data_dir}`  \n",
        f"**Fecha de analisis**: 2026-06-02  \n\n",
        "---\n\n",
    ]

    total_mb = sum(s["total_size_mb"] for s in all_stats)
    lines.append(f"**Total**: {len(all_stats)} workloads, {total_mb:.1f} MB\n\n")

    for stats in all_stats:
        lines.append(f"## {stats['name']}\n\n")
        lines.append(f"Tamano total: {stats['total_size_mb']:.1f} MB\n\n")

        if stats["xlsx_files"]:
            lines.append("### Ficheros Excel (resultados tabulados)\n\n")
            for f in stats["xlsx_files"]:
                lines.append(f"- `{f['name']}` ({f['size']})\n")
            lines.append("\n")

        if stats["json_files"]:
            lines.append(f"### Ficheros JSON ({len(stats['json_files'])} simulaciones)\n\n")
            if args.verbose:
                for f in stats["json_files"][:20]:
                    lines.append(f"- `{f['name']}` ({f['size']})\n")
                if len(stats["json_files"]) > 20:
                    lines.append(f"- ... y {len(stats['json_files']) - 20} mas\n")
            else:
                lines.append(f"  {len(stats['json_files'])} ficheros de datos de simulacion\n")
            lines.append("\n")

        if stats["png_files"]:
            lines.append(f"### Figuras ({len(stats['png_files'])} imagenes)\n\n")
            lines.append("\n")

    lines.extend([
        "---\n\n",
        "## Como analizar estos resultados\n\n",
        "### Opcion 1: Jupyter Notebook (recomendada)\n\n",
        "```bash\n",
        "# Instalar dependencias (Python 3.8 + venv recomendado)\n",
        "pip install pandas openpyxl matplotlib jupyter\n\n",
        "# Abrir notebook\n",
        "jupyter notebook python/notebooks/statistics_paper4.ipynb\n",
        "# Ajustar baseFolder en la primera celda a la ruta de paper4_data/\n",
        "```\n\n",
        "### Opcion 2: Docker\n\n",
        "```powershell\n",
        ".\\scripts\\docker_build_and_run.ps1 -Action jupyter\n",
        "# Abrir: http://localhost:8888\n",
        "```\n\n",
        "### Opcion 3: nbconvert (sin browser)\n\n",
        "```bash\n",
        "jupyter nbconvert --to notebook --execute python/notebooks/statistics_paper4.ipynb\n",
        "```\n\n",
        "---\n\n",
        "## Metricas objetivo (Tabla 6 del paper — PlanetLab)\n\n",
        "| Tecnica | Energy (kWh) | SLA (%) | Migrations | ESV |\n",
        "|---------|-------------|---------|-----------|-----|\n",
        "| WF      | 23.16       | 2.46    | 322       | 56.33 |\n",
        "| **WBF** | **23.15**   | **2.23** | **296** | **53.84** |\n\n",
    ])

    summary_path = output_dir / "available_results.md"
    with open(summary_path, "w", encoding="utf-8") as f:
        f.writelines(lines)

    # Guardar stats como JSON para uso programatico
    stats_path = output_dir / "workload_stats.json"
    with open(stats_path, "w", encoding="utf-8") as f:
        json.dump(all_stats, f, indent=2, ensure_ascii=False)

    print()
    print(f"Summary guardado en: {summary_path}")
    print(f"Stats JSON en: {stats_path}")
    print()
    print("Para analisis completo:")
    print("  1. Abrir python/notebooks/statistics_paper4.ipynb")
    print("  2. Ajustar baseFolder a la ruta de paper4_data/")
    print("  3. Ejecutar todas las celdas")
    print()
    print("O con Docker:")
    print("  .\\scripts\\docker_build_and_run.ps1 -Action jupyter")


if __name__ == "__main__":
    main()
