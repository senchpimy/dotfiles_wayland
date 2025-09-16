#!/bin/python
import subprocess

#text_to_animate = subprocess.run(["setsid","screenfetch", "-N"], capture_output=True, text=True, check=True).stdout
text_to_animate = subprocess.run(['pfetch'], capture_output=True, text=True, check=True).stdout

from terminaltexteffects.utils.graphics import Color
import pkgutil
import terminaltexteffects.effects
import random
import importlib
import inspect

from terminaltexteffects.engine.base_effect import BaseEffect
import re

def strip_ansi_codes(text: str) -> str:
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
    effect_module = importlib.import_module(f"terminaltexteffects.effects.{chosen_effect_name}")
except ImportError:
    print(f"No se pudo importar el módulo {chosen_effect_name}.")
    exit()

EffectClass = find_effect_class(effect_module)

if EffectClass:
    #result = subprocess.run(["fastfetch","-c", "none"], capture_output=True, text=True, check=True)
    #raw_output = result.stdout
    #text_to_animate = strip_ansi_codes(raw_output)
    color_texto =  '0f0f0f'
    
    try:
        text_to_animate = strip_ansi_codes(text_to_animate)
        effect = EffectClass(text_to_animate)
        effect.effect_config.final_gradient_stops = (Color(color_texto))

        try:
            with effect.terminal_output() as terminal:
                for frame in effect:
                    terminal.print(frame)
        except:
            #Terminar antes y no imprimir error de KeyboardInterrupt
            pass

    except Exception as e:
        print(f"Ocurrió un error al ejecutar el efecto: {e}")

else:
    print(f"No se pudo encontrar una clase de efecto válida en el módulo {chosen_effect_name}.")
