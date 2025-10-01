#!/usr/bin/env python3
import socket
import sys
import os

SOCKET_PATH = "/tmp/kbd_backlight.sock"

def main():
    if len(sys.argv) < 2:
        print("Uso: python3 cliente.py <comando>")
        print("Comandos disponibles:")
        print("  max              - Muestra el brillo máximo posible.")
        print("  set <numero>     - Establece el brillo a un valor específico.")
        sys.exit(1)

    if not os.path.exists(SOCKET_PATH):
        print(f"Error: No se pudo conectar al socket en {SOCKET_PATH}.")
        print("¿Estás seguro de que el script del servidor (control_teclado.py) se está ejecutando con sudo?")
        sys.exit(1)

    command = " ".join(sys.argv[1:])

    client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    try:
        client.connect(SOCKET_PATH)
        
        client.sendall(command.encode())

        response = client.recv(1024)
        
        print(response.decode().strip())

    except ConnectionRefusedError:
        print("Error: La conexión fue rechazada. Asegúrate de que el servidor está en ejecución y aceptando conexiones.")
    except Exception as e:
        print(f"Ocurrió un error inesperado: {e}")
    finally:
        client.close()

if __name__ == "__main__":
    main()
