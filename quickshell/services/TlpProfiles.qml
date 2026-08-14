pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

/**
 * Service que obtiene el perfil de energía desde el servidor TLP
 * (socket /tmp/tlp_manager.sock) a través de client.py.
 *
 * Mapeo TLP -> PowerProfile:
 *   Ahorro      -> PowerSaver
 *   Balanceado  -> Balanced
 *   Rendimiento -> Performance
 *   otro estado -> Balanced
 */
Singleton {
    id: root

    property int profile: PowerProfile.Balanced
    property bool hasPerformanceProfile: true
    property bool available: false

    function refresh() {
        if (!statusProc.running) {
            statusProc.running = true
        }
    }

    function cycle() {
        if (!root.available) return
        Quickshell.execDetached(["python3", "/home/plof/dotfiles_wayland/tlp/client.py", "--switch"])
        // El switch tarda un poco en aplicarse; recargamos tras un instante.
        refreshDelay.restart()
    }

    Timer {
        id: refreshDelay
        interval: 700
        repeat: false
        onTriggered: root.refresh()
    }

    Process {
        id: statusProc
        command: ["python3", "/home/plof/dotfiles_wayland/tlp/client.py"]
        stdout: StdioCollector {
            onStreamFinished: {
                const mode = text.trim()
                root.available = mode !== "" && mode !== "Sin plantillas"
                switch (mode) {
                case "Ahorro":
                    root.profile = PowerProfile.PowerSaver
                    break
                case "Balanceado":
                    root.profile = PowerProfile.Balanced
                    break
                case "Rendimiento":
                    root.profile = PowerProfile.Performance
                    break
                case "Personalizado":
                case "Sin plantillas":
                default:
                    root.profile = PowerProfile.Balanced
                    break
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) root.available = false
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
