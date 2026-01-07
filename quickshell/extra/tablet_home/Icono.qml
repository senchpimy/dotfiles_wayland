import QtQuick
import Quickshell
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import QtQuick.Controls
import QtQuick.Shapes 

Item {
    // Tamaño explícito + política de tamaño
    width: 100
    height: 100
    Layout.preferredWidth: 100
    Layout.preferredHeight: 100
    
    Rectangle {
        anchors.fill: parent
        color: "white"
        radius: 15
        border.width: 2
        border.color: "#40000000"
        
        // Sombras para mejor visibilidad
        layer.enabled: true
        layer.effect: DropShadow {
            radius: 8
            samples: 16
            color: "#80000000"
        }
    }
}
