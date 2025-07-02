import subprocess
import requests
import sys

def verificar_acceso(url):
    try:
        respuesta = requests.head(url, timeout=2)
        if respuesta.status_code == 200:
            print(url)
    except:
        import os
        script_path = os.path.dirname(os.path.abspath(__file__))
        image_path = os.path.join(script_path, "no_image.jpg")
        print(image_path)

def obtener_url(player):
    try:
        url = subprocess.check_output(
            ["playerctl", "metadata", "mpris:artUrl", "-p", player],
            text=True
        ).strip()

        if url.startswith("https"):
            verificar_acceso(url)
        else:
            print(url)
    except:
        print()


if len(sys.argv) < 2:
    print("Uso: python script.py <nombre_del_reproductor>")
    sys.exit(1)

player_name = sys.argv[1]
obtener_url(player_name)

