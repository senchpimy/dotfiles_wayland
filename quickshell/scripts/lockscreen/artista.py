import subprocess
import requests
import sys
import os

no_img = "no_image.jpg"
img = "image.jpg"
script_path = os.path.dirname(os.path.abspath(__file__))
# The project root is two levels up from scripts/lockscreen/
root_path = os.path.abspath(os.path.join(script_path, "../../"))
no_image_path = os.path.join(root_path, "assets/lockscreen", no_img)
image_path = os.path.join(root_path, "assets/lockscreen", img)


def no_image():
    import shutil

    shutil.copy(no_image_path, image_path)
    print(image_path)
    pass


def verificar_acceso(url):
    try:
        respuesta = requests.get(url, timeout=2)
        if respuesta.status_code == 200:
            img_data = respuesta.content
            with open(image_path, "wb") as hand:
                hand.write(img_data)
            print(image_path)
    except:
        no_image()


def obtener_url(player):
    try:
        url = subprocess.check_output(
            ["playerctl", "metadata", "mpris:artUrl", "-p", player], text=True
        ).strip()

        if url.startswith("https") or url.startswith("http"):
            verificar_acceso(url)
        elif url.startswith("file://"):
            import shutil
            local_path = url[7:]
            try:
                shutil.copy(local_path, image_path)
                print(image_path)
            except:
                no_image()
        else:
            no_image()
    except:
        no_image()


if len(sys.argv) < 2:
    print("Uso: python script.py <nombre_del_reproductor>")
    sys.exit(1)
player_name = sys.argv[1]
obtener_url(player_name)
