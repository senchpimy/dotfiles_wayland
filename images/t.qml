import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: w

            property var modelData
            screen: modelData
            visible: modelData.primary
            WlrLayershell.layer: WlrLayer.Bottom

            anchors {
                top: true
                right: true
            }
            margins {
                top: 30
                right: 30
            }
            
            implicitWidth: container.width
            implicitHeight: container.height
            color: "transparent"

            Item {
                id: container
                width: 170
                height: 270

                // --- CAPA 1: CONTENIDO (GRADIENTE + GIF) ---
                // Este Rectangle es el fondo visible y contiene la animación.
                // Como su fondo de gradiente es opaco, SOLUCIONA EL GHOSTING.
                Rectangle {
                    id: contentLayer
                    anchors.fill: parent
                    radius: 12
                    clip: true // Esencial para recortar el GIF

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#4cffffff" }
                        GradientStop { position: 0.5; color: "#66000000" }
                        GradientStop { position: 0.5; color: "#80000000" }
                        GradientStop { position: 1.0; color: "#b3000000" }
                    }

                    AnimatedImage {
                        id: myGif
                        anchors.fill: parent
                        source: "gif1.gif"
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                Rectangle {
                    id: effectsOverlay
                    anchors.fill: parent
                    radius: 12
                    color: "transparent" // Es solo un marco para los efectos

                    border.width: 2
                    border.color: "#40ffffff"

                    InnerShadow {
                        anchors.fill: parent
                        source: parent // La sombra sigue la forma de este Rectangle
                        radius: 12
                        samples: 24
                        color: "#40000000" 
                        horizontalOffset: 0
                        verticalOffset: 0
                    }
                }
            }
        }
    }
}
