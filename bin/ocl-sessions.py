#!/usr/bin/env python3
"""Lista todas las sesiones de OpenCode en una tabla legible.

Uso:
    ocl              # sesiones principales (sin subsesiones)
    ocl -a           # incluye subsesiones
    ocl nasa         # filtra por texto en título o carpeta
    ocl -a -n 20     # incluye subsesiones, solo las 20 más recientes
    ocl --legacy     # muestra sesiones viejas que opencode ya no puede abrir

El ID completo siempre se muestra (para reanudar con opencode -s <id>).
Los títulos largos se recortan con …
"""
import argparse
import datetime as dt
import os
import shutil
import sqlite3
import sys
import unicodedata

from wcwidth import wcswidth

DB = os.path.expanduser("~/.local/share/opencode/opencode.db")
HOME = os.path.expanduser("~")
MESES = ["ene", "feb", "mar", "abr", "may", "jun",
         "jul", "ago", "sep", "oct", "nov", "dic"]

# Solo la tabla viva: las filas que únicamente están en `session` (v1) son
# restos de sesiones borradas o no migradas, y opencode responde "Session not found".
QUERY = """
SELECT id, title, directory, time_created, COALESCE(parent_id, '') AS pid
FROM session_v2
ORDER BY time_created DESC
"""

QUERY_LEGACY = """
SELECT id, title, directory, time_created, COALESCE(parent_id, '') AS pid
FROM session
WHERE id NOT IN (SELECT id FROM session_v2)
ORDER BY time_created DESC
"""

QUERY_SUBSESIONES = """
SELECT COUNT(*) FROM session_v2 WHERE COALESCE(parent_id, '') <> ''
"""

QUERY_LEGACY_TOTAL = """
SELECT COUNT(*) FROM session WHERE id NOT IN (SELECT id FROM session_v2)
"""

# colores ANSI
RESET = "\033[0m"
BOLD = "\033[1m"
DIM = "\033[90m"
CYAN = "\033[36m"
BLUE = "\033[34m"


def ancho(texto: str) -> int:
    return max(0, wcswidth(texto))


def recorta(texto: str, limite: int) -> str:
    """Recorta a `limite` columnas de terminal añadiendo … al final."""
    if ancho(texto) <= limite:
        return texto
    salida = ""
    for ch in texto:
        if ancho(salida + ch) > limite - 1:
            break
        salida += ch
    return salida.rstrip() + "…"


def recorta_izquierda(texto: str, limite: int) -> str:
    """Recorta a `limite` columnas conservando el final (más informativo)."""
    if ancho(texto) <= limite:
        return texto
    salida = ""
    for ch in reversed(texto):
        if ancho(ch + salida) > limite - 1:
            break
        salida = ch + salida
    return "…" + salida.lstrip()


def rellena(texto: str, limite: int) -> str:
    return texto + " " * max(0, limite - ancho(texto))


def fecha_bonita(ms: int) -> str:
    d = dt.datetime.fromtimestamp(ms / 1000)
    hoy = dt.date.today()
    if d.date() == hoy:
        return f"hoy {d:%H:%M}"
    if d.date() == hoy - dt.timedelta(days=1):
        return f"ayer {d:%H:%M}"
    if d.year == hoy.year:
        return f"{d.day:2d} {MESES[d.month - 1]} {d:%H:%M}"
    return f"{d.day:2d} {MESES[d.month - 1]} {d.year}"


def carpeta_bonita(ruta: str) -> str:
    if ruta == HOME:
        return "~"
    if ruta.startswith(HOME + "/"):
        return "~/" + ruta[len(HOME) + 1:]
    return ruta


def normaliza(texto: str) -> str:
    sin_acentos = "".join(
        c for c in unicodedata.normalize("NFD", texto)
        if unicodedata.category(c) != "Mn"
    )
    return sin_acentos.lower()


def main() -> int:
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("-a", "--all", action="store_true", help="incluir subsesiones")
    parser.add_argument("-n", "--limit", type=int, default=0)
    parser.add_argument("-i", "--ids", action="store_true", help="(por defecto) mostrar el ID")
    parser.add_argument("-L", "--legacy", action="store_true",
                        help="incluir sesiones obsoletas (opencode ya no las abre)")
    parser.add_argument("-h", "--help", action="store_true")
    parser.add_argument("filtro", nargs="*")
    args = parser.parse_args()

    if args.help:
        print(__doc__.strip())
        return 0

    if not os.path.exists(DB):
        print(f"No encuentro la base de datos: {DB}", file=sys.stderr)
        return 1

    con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    vivas = con.execute(QUERY).fetchall()
    if not args.all:
        vivas = [f for f in vivas if not f[4]]
    filas = [(f[0], f[1], f[2], f[3], False) for f in vivas]
    subsesiones = con.execute(QUERY_SUBSESIONES).fetchone()[0]
    obsoletas = con.execute(QUERY_LEGACY_TOTAL).fetchone()[0]
    if args.legacy:
        filas += [(f[0], f[1], f[2], f[3], True)
                  for f in con.execute(QUERY_LEGACY).fetchall()]
        filas.sort(key=lambda f: f[3], reverse=True)
    con.close()

    filtro = normaliza(" ".join(args.filtro).strip())
    if filtro:
        filas = [f for f in filas
                 if filtro in normaliza(f[0])
                 or filtro in normaliza(f[1])
                 or filtro in normaliza(f[2])]

    if args.limit:
        filas = filas[: args.limit]

    if not filas:
        print("Sin sesiones que coincidan.", file=sys.stderr)
        return 0

    tty = sys.stdout.isatty() and os.environ.get("NO_COLOR") is None
    if not tty:
        global RESET, BOLD, DIM, CYAN, BLUE
        RESET = BOLD = DIM = CYAN = BLUE = ""

    ancho_total = shutil.get_terminal_size((110, 24)).columns
    w_fecha = 11
    w_id = 32  # el ID completo siempre visible
    # La carpeta cede espacio primero; el título se lleva el resto.
    extras = w_fecha + 2 + (w_id + 2 if w_id else 0)
    base = ancho_total - extras - 2
    # El título se queda con la mitad del espacio y se recorta; la carpeta usa el resto.
    w_titulo = max(16, base // 2)
    w_dir = min(40, base - w_titulo)
    if w_dir < 8:
        w_dir = 0

    cabecera = f"{BOLD}{rellena('FECHA', w_fecha)}  {rellena('TÍTULO', w_titulo)}"
    if w_dir:
        cabecera += f"  {rellena('CARPETA', w_dir)}"
    if w_id:
        cabecera += f"  {rellena('ID', w_id)}"
    cabecera += RESET
    print(cabecera)
    ancho_linea = w_fecha + 2 + w_titulo
    if w_dir:
        ancho_linea += 2 + w_dir
    if w_id:
        ancho_linea += 2 + w_id
    print(f"{DIM}{'─' * min(ancho_total, ancho_linea)}{RESET}")

    for sid, titulo, directorio, ts, obsoleta in filas:
        if obsoleta:
            titulo = f"⚠ {titulo} (obsoleta)"
        lineas = [recorta(titulo, w_titulo)] if titulo else [""]
        d = recorta_izquierda(carpeta_bonita(directorio), w_dir) if w_dir else ""
        for i, linea in enumerate(lineas):
            if i == 0:
                salida = (f"{CYAN}{rellena(fecha_bonita(ts), w_fecha)}{RESET}  "
                          f"{BOLD}{rellena(linea, w_titulo)}{RESET}")
                if w_dir:
                    salida += f"  {BLUE}{rellena(d, w_dir)}{RESET}"
                if w_id:
                    salida += f"  {BOLD}{rellena(sid, w_id)}{RESET}"
            else:
                salida = (f"{' ' * w_fecha}  "
                          f"{BOLD}{rellena(linea, w_titulo)}{RESET}")
            print(salida)

    n = len(filas)
    resumen = f"{n} {'sesión' if n == 1 else 'sesiones'}"
    if filtro:
        resumen += f" (filtro: {' '.join(args.filtro)})"
    if not args.all and subsesiones:
        resumen += f" · {subsesiones} subsesiones ocultas (-a para verlas)"
    if not args.legacy and obsoletas:
        resumen += f" · {obsoletas} obsoletas no mostradas (-L para verlas)"
    print(f"\n{DIM}{resumen}{RESET}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
