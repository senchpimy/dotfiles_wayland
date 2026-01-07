import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Controls
import Quickshell.Io
import Qt5Compat.GraphicalEffects

Item {
    id: main
    visible: false


    Loader {
        id: strLoad
        source: "ImagePath.qml"
    }

    property var player: ""
    property var image: ""
    property var artist: ""
    property var name: ""
    property int imageVersion: 0
    readonly property string imageBasePath: "file:///home/plof/.config/quickshell/extra/lockscreen/image.jpg"

    readonly property var test: Process {
        running: true
        command: ["playerctl", "-l"]
        //manageLifetime: false
        stdout: SplitParser {
            onRead: data => {
                if (data === "spotify") {
                    main.visible = true
                }
            }
        }
    }

    readonly property var tog: Process {
        command: ["playerctl", "play-pause", "-p", player]
        //manageLifetime: false
    }

    readonly property var next: Process {
        command: ["playerctl", "next", "-p", player]
        //manageLifetime: false
    }

    readonly property var previous: Process {
        command: ["playerctl", "previous", "-p", player]
        //manageLifetime: false
    }

    readonly property var artistP: Process {
        running: true
        command: ["playerctl", "metadata", "artist", "-p", player]
        //manageLifetime: false
        stdout: SplitParser {
            onRead: data => {
                artist = data
            }
        }
    }

    readonly property var nameP: Process {
        running: true
        command: ["playerctl", "metadata", "title", "-p", player]
        //manageLifetime: false
        stdout: SplitParser {
            onRead: data => {
                if (data.length < 32) {
                    name = data
                } else {
                    name = data.slice(0, 32) + "..."
                }
            }
        }
    }

    readonly property var cover: Process {
        command: ["python", "/home/plof/.config/quickshell/extra/lockscreen/artista.py", player]
        stdout: SplitParser {
            onRead: data => {
                // 'data' será la ruta que imprimió el script de Python.
                // Simplemente incrementamos la versión para forzar la recarga.
                //console.log("Recibida señal de recarga de imagen: " + data)
                imageVersion++ // ¡Esta es la magia!
            }
        }
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: {
            cover.running = true
            artistP.running = true
            nameP.running = true
        }
    }

    anchors {
        horizontalCenter: parent.horizontalCenter
        top: parent.verticalCenter
    }

    ColumnLayout {
        anchors {
            horizontalCenter: parent.horizontalCenter
        }

        // Contenedor principal con degradado verde translúcido
        Rectangle {
            height: 150
            width: 600
            radius: 20

            gradient: Gradient {
                GradientStop { position: 0.0; color: strLoad.item.containerGradientStart }
                GradientStop { position: 1.0; color: strLoad.item.containerGradientEnd }
            }

            border.color: strLoad.item.containerBorderColor
            border.width: 1

            layer.enabled: true
            layer.effect: DropShadow {
                color: strLoad.item.containerShadowColor
                radius: 12
                samples: 20
                horizontalOffset: 0
                verticalOffset: 5
            }
        }

        Rectangle {
            anchors {
                top: parent.top
            }

            RowLayout {
                spacing: 180

                Item {
                    anchors {
                        top: parent.top
                        left: parent.left
                        leftMargin: 10
                        topMargin: img.width !== img.height ? 15 : 10
                    }

                    Image {
                        id: img
                        //source: image
                        //source: "https://i.scdn.co/image/ab67616d0000b273d754d2ef29e3f7dcd73caa3b"
                        //source: "image.jpg"
                        source: imageBasePath + "?v=" + imageVersion
                        width: 130
                        fillMode: Image.PreserveAspectFit
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Item {
                                width: img.width
                                height: img.height
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: img.width
                                    height: img.height
                                    radius: 20
                                    color: "black"
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    anchors {
                        top: parent.top
                        topMargin: 90
                    }

                    // Título de la canción (cambiamos solo el color):
                    Text {
                        anchors {
                            top: parent.top
                            topMargin: -80
                        }
                        text: name
                        font.pointSize: 21
                        font.bold: true
                        color: "#E0E4DB"  // Color más claro para mayor visibilidad
                    }

                    Text {
                        anchors {
                            top: parent.top
                            topMargin: -40
                        }
                        text: artist
                        font.pointSize: 15
                        color: "#555555"
                    }

                    RowLayout {
                        spacing: 90

                        Button {
                            id: p
                            implicitHeight: 45
                            implicitWidth: 45
                            onClicked: {
                                previous.running = true
                            }

                            background: Rectangle {
                                color: "transparent"
                            }

                            Image {
                                width: parent.width
                                height: parent.height
                                source: "previous.svg"
                                anchors.centerIn: parent
                                fillMode: Image.PreserveAspectFit
                            }

                            // Animación de escala al hacer clic
                            PropertyAnimation {
                                id: pAnimation
                                target: p
                                property: "scale"
                                to: 0.8
                                duration: 100
                                easing.type: Easing.InOutQuad
                            }
                            // Restaurar escala al soltar
                            PropertyAnimation {
                                id: pAnimationReverse
                                target: p
                                property: "scale"
                                to: 1.0
                                duration: 100
                                easing.type: Easing.InOutQuad
                            }
                            onPressed: pAnimation.start()
                            onReleased: pAnimationReverse.start()
                        }

                        Button {
                            id: play_pause
                            implicitHeight: 45
                            implicitWidth: 45
                            onClicked: {
                                tog.running = true
                            }

                            background: Rectangle {
                                color: "transparent"
                            }

                            Image {
                                width: parent.width
                                height: parent.height
                                source: "play-pause.svg"
                                anchors.centerIn: parent
                                fillMode: Image.PreserveAspectFit
                            }

                            PropertyAnimation {
                                id: playPauseAnimation
                                target: play_pause
                                property: "scale"
                                to: 0.8
                                duration: 100
                                easing.type: Easing.InOutQuad
                            }
                            PropertyAnimation {
                                id: playPauseAnimationReverse
                                target: play_pause
                                property: "scale"
                                to: 1.0
                                duration: 100
                                easing.type: Easing.InOutQuad
                            }
                            onPressed: playPauseAnimation.start()
                            onReleased: playPauseAnimationReverse.start()
                        }

                        Button {
                            id: n
                            implicitHeight: 45
                            implicitWidth: 45
                            onClicked: {
                                next.running = true
                            }

                            background: Rectangle {
                                color: "transparent"
                            }

                            Image {
                                width: parent.width
                                height: parent.height
                                source: "next.svg"
                                anchors.centerIn: parent
                                fillMode: Image.PreserveAspectFit
                            }

                            PropertyAnimation {
                                id: nAnimation
                                target: n
                                property: "scale"
                                to: 0.8
                                duration: 100
                                easing.type: Easing.InOutQuad
                            }
                            PropertyAnimation {
                                id: nAnimationReverse
                                target: n
                                property: "scale"
                                to: 1.0
                                duration: 100
                                easing.type: Easing.InOutQuad
                            }
                            onPressed: nAnimation.start()
                            onReleased: nAnimationReverse.start()
                        }
                    }
                }
            }
        }
    }
}
