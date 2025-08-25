#!/usr/bin/env python3
import os
import socket
import shutil
import subprocess
import sys
import stat
import filecmp

TLP_CONF = "/etc/tlp.conf"
TLP_SAVE = "/etc/tlp.save"  # Plantilla para modo Ahorro
TLP_PERF = "/etc/tlp.perf"  # Plantilla para modo Rendimiento

SOCKET_PATH = "/tmp/tlp_manager.sock"


def restart_tlp():
    try:
        subprocess.run(["systemctl", "restart", "tlp"], check=True)
        print("[+] TLP reiniciado correctamente.")
    except subprocess.CalledProcessError as e:
        print(f"[!] Error al reiniciar TLP: {e}")
    except FileNotFoundError:
        print(
            "[!] Error: El comando 'systemctl' no fue encontrado. ¿Estás en un sistema con systemd?"
        )

def get_current_mode():
    """
    Determina el modo de TLP actual comparando el contenido de tlp.conf
    con las plantillas.
    Devuelve: 'Ahorro', 'Rendimiento', 'Personalizado', o 'No encontrado'.
    """
    if not os.path.exists(TLP_CONF):
        return "No encontrado"
    
    if filecmp.cmp(TLP_CONF, TLP_SAVE, shallow=False):
        return "Ahorro"
    elif filecmp.cmp(TLP_CONF, TLP_PERF, shallow=False):
        return "Rendimiento"
    else:
        return "Personalizado" # El archivo existe pero no coincide con ninguna plantilla


def switch_config():
    if not os.path.exists(TLP_SAVE) or not os.path.exists(TLP_PERF):
        print(
            f"[!] Error: No se encontraron los archivos de configuración base '{TLP_SAVE}' o '{TLP_PERF}'."
        )
        return

    current_mode_is_save = False
    if os.path.exists(TLP_CONF):
        current_mode_is_save = filecmp.cmp(TLP_CONF, TLP_SAVE, shallow=False)

    if current_mode_is_save:
        print("[*] Modo actual: Ahorro. Cambiando a Rendimiento.")
        shutil.copy(TLP_PERF, TLP_CONF)
    else:
        print("[*] Modo actual: Rendimiento o Desconocido. Cambiando a Ahorro.")
        shutil.copy(TLP_SAVE, TLP_CONF)

    restart_tlp()


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
                if data:
                    command = data.decode().strip()
                    print(f"[*] Comando recibido: {command}")
                    if command == "switch":
                        switch_config()
                        conn.sendall(b"OK: Configuracion cambiada.\n")
                    else:
                        current_mode = get_current_mode()
                        response = f"{current_mode}\n"
                        conn.sendall(response.encode())
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

    run_server()
