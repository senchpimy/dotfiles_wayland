#!/usr/bin/env python3
import sys
import gi

# Especificamos que usaremos GTK 3
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

def obtener_ruta_icono(nombre_icono, tamano=48):
    """
    Busca el icono 'nombre_icono' en el tema GTK actual con el tamaño especificado.
    Retorna la ruta del archivo del icono o None si no se encuentra.
    """
    icon_theme = Gtk.IconTheme.get_default()
    icon_info = icon_theme.lookup_icon(nombre_icono, tamano, 0)
    if icon_info is not None:
        return icon_info.get_filename()
    return None

def main():
    if len(sys.argv) < 2:
        print("Uso: {} <nombre_icono> [tamano]".format(sys.argv[0]))
        sys.exit(1)

    nombre_icono = sys.argv[1]
    tamano = 48  # Tamaño por defecto
    if len(sys.argv) >= 3:
        try:
            tamano = int(sys.argv[2])
        except ValueError:
            print("El tamaño debe ser un número entero.")
            sys.exit(1)

    ruta = obtener_ruta_icono(nombre_icono, tamano)
    if ruta:
        print("Ruta del icono:", ruta)
    else:
        print("Icono '{}' no encontrado en el tema actual.".format(nombre_icono))

if __name__ == '__main__':
    main()
