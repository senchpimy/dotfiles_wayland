#!/bin/python
import subprocess
import re
from itertools import zip_longest

# Se importan al principio para que esten disponibles
from terminaltexteffects.utils.graphics import Color
import pkgutil
import terminaltexteffects.effects
import random
import importlib
import inspect
from terminaltexteffects.engine.base_effect import BaseEffect


def strip_ansi_codes(text: str) -> str:
    """Elimina los códigos de escape ANSI de un string."""
    ansi_escape_pattern = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
    return ansi_escape_pattern.sub('', text)


def find_effect_class(module):
    for name, obj in inspect.getmembers(module):
        if inspect.isclass(obj) and issubclass(obj, BaseEffect) and obj is not BaseEffect:
            return obj
    return None


package_path = terminaltexteffects.effects.__path__
effect_names = [name for _, name, _ in pkgutil.iter_modules(package_path)]

chosen_effect_name = random.choice(effect_names)

try:
    effect_module = importlib.import_module(
        f"terminaltexteffects.effects.{chosen_effect_name}")
except ImportError:
    print(f"No se pudo importar el módulo {chosen_effect_name}.")
    exit()

EffectClass = find_effect_class(effect_module)

if EffectClass:
    # --- INICIO DE LA LÓGICA DE RECONSTRUCCIÓN DE DISEÑO ---
    try:
        # Paso 1: Capturar SOLO el logo (-L) y limpiarlo de códigos ANSI.
        logo_result = subprocess.run(
            ["setsid", "screenfetch", "-L"],
            capture_output=True, text=True, check=True
        )
        logo_lines = strip_ansi_codes(logo_result.stdout).splitlines()

        # Paso 2: Capturar SOLO la información (-N) y limpiarla.
        info_result = subprocess.run(
            ["setsid", "screenfetch", "-N"],
            capture_output=True, text=True, check=True
        )
        info_lines = strip_ansi_codes(info_result.stdout).splitlines()

        # Paso 3: Combinar logo e información, línea por línea.
        logo_width = max(len(line) for line in logo_lines) if logo_lines else 0
        gutter = 4  # Espacio entre el logo y el texto.

        combined_lines = []
        for logo_line, info_line in zip_longest(logo_lines, info_lines, fillvalue=""):
            formatted_logo = f"{logo_line:<{logo_width + gutter}}"
            combined_lines.append(f"{formatted_logo}{info_line}")

        text_to_animate = "\n".join(combined_lines)

    except (FileNotFoundError, subprocess.CalledProcessError) as e:
        # Texto de respaldo si screenfetch falla.
        text_to_animate = f"screenfetch falló: {e}"
    # --- FIN DE LA LÓGICA DE RECONSTRUCCIÓN ---

    color_texto = '0f0f0f'

    try:
        effect = EffectClass(text_to_animate)
        effect.effect_config.final_gradient_stops = (Color(color_texto))

        try:
            with effect.terminal_output() as terminal:
                for frame in effect:
                    terminal.print(frame)
        except KeyboardInterrupt:
            # Terminar antes y no imprimir error de KeyboardInterrupt
            pass

    except Exception as e:
        print(f"Ocurrió un error al ejecutar el efecto: {e}")

else:
    print(f"No se pudo encontrar una clase de efecto válida en el módulo {
          chosen_effect_name}.")
