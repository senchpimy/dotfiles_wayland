import QtQuick
import QtQuick.Controls
import Quickshell.Io // Importante para poder usar el componente Process

/**
 * Un widget simple con un único botón que envía una notificación
 * de escritorio al ser presionado, usando un script de Python.
 */
Item {
    id: root
    width: 300
    height: 150

    // El componente Process se encarga de ejecutar comandos externos.
    // Lo configuramos para que no se ejecute al iniciar (running: false).
    Process {
        id: notificationProc
        running: false // No se ejecuta al cargar, solo cuando lo activemos.

        // El comando a ejecutar. Es un array de strings.
        // 1. "python": El ejecutable.
        // 2. "-c": Le dice a Python que ejecute el siguiente string como un script.
        // 3. El script de Python:
        //    - import os: Importa el módulo 'os' para interactuar con el sistema.
        //    - os.system(...): Ejecuta un comando de la terminal.
        //    - 'notify-send "Título" "Mensaje"': Es el comando que envía la notificación.
        //      Usamos comillas simples para el script de Python y dobles para el mensaje.
        command: [
            "python",
            "-c",
            "import os; os.system('notify-send \"Notificación desde QML\" \"¡El botón fue presionado!\"')"
        ]

        // (Opcional) Para ver si hubo errores en la consola.
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.error("El proceso de notificación falló. Código de salida:", exitCode);
            } else {
                console.log("Notificación enviada con éxito.");
            }
        }
    }

    // El único botón en nuestra interfaz.
    Button {
        id: notificationButton

        // Descripción del botón.
        text: qsTr("Enviar Notificación")

        // Lo centramos en el componente padre (el Item 'root').
        anchors.centerIn: parent

        // Esta es la acción que se ejecuta al hacer clic.
        onClicked: {
            // Imprimimos un mensaje en la consola para depuración.
            console.log("Botón presionado. Ejecutando el proceso de notificación...")

            // Para asegurar que el proceso se ejecute cada vez que hacemos clic,
            // primero lo detenemos (si estuviera corriendo) y luego lo iniciamos.
            notificationProc.running = false
            notificationProc.running = true
        }
    }
}
