import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
// Eliminar:
// import Qt5Compat.GraphicalEffects

// Agregar en su lugar:

Rectangle {
    id: root
    // Asegurar tamaño explícito
    width: parent.width
    height: parent.height
    color: "transparent"

    Loader {
        id: strLoad
        source: "../lockscreen/ImagePath.qml"
    }

    Image {
        id: image
        source: strLoad.item.path
        anchors.fill: parent
        z: 0 // Capa inferior
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        interactive: true
        z: 1 // Capa superior

        Repeater {
            model: 3
            delegate: Area {
                width: swipeView.width
                height: swipeView.height
                
                Repeater {
                    model: 15
                    Icono {
                        // Color temporal para visibilidad
                        Rectangle {
                            anchors.fill: parent
                            color: "#80ff0000" // Rojo semi-transparente
                            border.width: 2
                            radius: 10
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: blurContainment
        anchors.fill: parent
        color: "transparent"
        z: 2 // Capa superior si necesitas interacción
    }
}
