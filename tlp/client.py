#!/usr/bin/env python3
import argparse
import subprocess
import sys

def get_available_profiles():
    """
    Ejecuta 'powerprofilesctl list' y devuelve una lista ordenada de los
    perfiles disponibles.
    """
    try:
        # Ejecuta el comando para listar los perfiles
        result = subprocess.run(
            ["powerprofilesctl", "list"],
            capture_output=True,
            text=True,
            check=True
        )
        
        # Procesa la salida para extraer solo los nombres de los perfiles
        profiles = []
        for line in result.stdout.strip().split('\n'):
            if ':' in line:
                # Limpia el nombre, quitando el '*' y espacios en blanco
                profile_name = line.split(':')[0].replace('*', '').strip()
                profiles.append(profile_name)
        
        # Asegura un orden consistente (performance -> balanced -> power-saver)
        # Esto es opcional, pero hace que el ciclo sea predecible.
        ordered_profiles = ['performance', 'balanced', 'power-saver']
        return [p for p in ordered_profiles if p in profiles]

    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Error: No se pudo ejecutar 'powerprofilesctl'. ¿Está instalado power-profiles-daemon?", file=sys.stderr)
        sys.exit(1)

def get_current_profile():
    """
    Ejecuta 'powerprofilesctl get' y devuelve el nombre del perfil activo.
    """
    try:
        result = subprocess.run(
            ["powerprofilesctl", "get"],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Error: No se pudo ejecutar 'powerprofilesctl'. ¿Está instalado power-profiles-daemon?", file=sys.stderr)
        sys.exit(1)

def set_profile(profile_name):
    """
    Establece un nuevo perfil de energía usando 'powerprofilesctl set'.
    """
    try:
        subprocess.run(
            ["powerprofilesctl", "set", profile_name],
            check=True,
            capture_output=True # Captura para que no imprima nada en la terminal
        )
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        print(f"Error: No se pudo establecer el perfil '{profile_name}'.", file=sys.stderr)
        return False


# --- Lógica Principal del Script ---
if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Cliente para gestionar perfiles de power-profiles-daemon."
    )
    parser.add_argument(
        "-s",
        "--switch",
        action="store_true",
        help="Cambia al siguiente perfil de energía en el ciclo.",
    )
    parser.add_argument(
        '-m',
        "--mode",
        action="store_true",
        help="Obten el modo actual de el sistema"
    )

    args = parser.parse_args()

    if args.switch:
        all_profiles = get_available_profiles()
        if not all_profiles:
            print("No se encontraron perfiles de energía disponibles.", file=sys.stderr)
            sys.exit(1)
            
        current = get_current_profile()
        
        try:
            # Encuentra el índice del perfil actual
            current_index = all_profiles.index(current)
            # Calcula el índice del siguiente perfil, volviendo al inicio si es necesario
            next_index = (current_index + 1) % len(all_profiles)
            next_profile = all_profiles[next_index]
            
            # Establece el nuevo perfil
            if set_profile(next_profile):
                print(f"Cambiado de '{current}' a '{next_profile}'")
                subprocess.run(["notify-send", "Perfil de Energía", f"Cambiado a {next_profile}"])

        except ValueError:
            print(f"El perfil actual '{current}' no se encuentra en la lista de perfiles disponibles. Estableciendo a 'balanced'.", file=sys.stderr)
            set_profile("balanced")

    if args.mode:
        current = get_current_profile()
        print(current)
