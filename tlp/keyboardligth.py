#!/usr/bin/env python3
import os
import socket
import sys
import stat
import glob

SOCKET_PATH = "/tmp/kbd_backlight.sock"
KBD_BACKLIGHT_PATH = None

def find_kbd_backlight_path():
    possible_paths = glob.glob("/sys/class/leds/*::kbd_backlight")
    if possible_paths:
        return possible_paths[0]
    possible_paths = glob.glob("/sys/class/leds/*kbd_backlight*")
    if possible_paths:
        return possible_paths[0]
    return None

def get_max_brightness():
    try:
        with open(os.path.join(KBD_BACKLIGHT_PATH, "max_brightness"), "r") as f:
            return f.read().strip()
    except FileNotFoundError:
        return "ERROR: No se pudo leer el brillo máximo."
    except Exception as e:
        return f"ERROR: {e}"

def set_brightness(value_str):
    try:
        max_b = int(get_max_brightness())
        value = int(value_str)

        if 0 <= value <= max_b:
            with open(os.path.join(KBD_BACKLIGHT_PATH, "brightness"), "w") as f:
                f.write(str(value))
            return f"OK: Brillo establecido a {value}."
        else:
            return f"ERROR: El valor debe estar entre 0 y {max_b}."
    except ValueError:
        return "ERROR: El valor proporcionado no es un número válido."
    except Exception as e:
        return f"ERROR: No se pudo establecer el brillo: {e}"

def run_server():
    if os.path.exists(SOCKET_PATH):
        os.remove(SOCKET_PATH)

    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

    try:
        server.bind(SOCKET_PATH)
        os.chmod(SOCKET_PATH, stat.S_IRWXU | stat.S_IRWXG | stat.S_IRWXO)
        server.listen(1)
        print(f"[+] Servidor escuchando en {SOCKET_PATH}")

        while True:
            conn, _ = server.accept()
            with conn:
                data = conn.recv(1024)
                if not data:
                    continue

                command = data.decode().strip()
                print(f"[*] Comando recibido: '{command}'")

                response = ""
                if command == "max":
                    response = get_max_brightness()
                elif command.startswith("set "):
                    parts = command.split()
                    if len(parts) == 2:
                        response = set_brightness(parts[1])
                    else:
                        response = "ERROR:Use: set <numero>"
                else:
                    response = "ERROR: Comando no reconocido."

                conn.sendall(response.encode() + b'\n')

    except Exception as e:
        print(f"[!] Error en el servidor: {e}")
    finally:
        server.close()
        if os.path.exists(SOCKET_PATH):
            os.remove(SOCKET_PATH)
        print("\n[+] Servidor detenido y socket limpiado.")


if __name__ == "__main__":
    if os.geteuid() != 0:
        print("[!] Este script debe ejecutarse con privilegios de root (sudo).")
        sys.exit(1)

    KBD_BACKLIGHT_PATH = find_kbd_backlight_path()
    if not KBD_BACKLIGHT_PATH:
        print("[!] Error: No se pudo encontrar el dispositivo de retroiluminación del teclado en /sys/class/leds/")
        sys.exit(1)
    
    print(f"[*] Dispositivo de teclado encontrado en: {KBD_BACKLIGHT_PATH}")
    run_server()
