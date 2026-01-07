import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Controls
import Quickshell.Io
import Qt5Compat.GraphicalEffects

Item {
    id: main
    visible: false
    property var player: ""
    property var image: ""
    property var artist: ""
    property var name: ""

    readonly property var test: Process {
        running: true
        command: ["playerctl", "-l"]
        manageLifetime: false
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
        manageLifetime: false
    }

    readonly property var next: Process {
        command: ["playerctl", "next", "-p", player]
        manageLifetime: false
    }

    readonly property var previous: Process {
        command: ["playerctl", "previous", "-p", player]
        manageLifetime: false
    }

    readonly property var artistP: Process {
        running: true
        command: ["playerctl", "metadata", "artist", "-p", player]
        manageLifetime: false
        stdout: SplitParser {
            onRead: data => {
                artist = data
            }
        }
    }

    readonly property var nameP: Process {
        running: true
        command: ["playerctl", "metadata", "title", "-p", player]
        manageLifetime: false
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

    Process {
        id: artistProcess
        command: ["python", "/home/plof/.config/quickshell/lockscreen/artista.py", player]
        onStdoutReceived: {


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

    // Fondo con efecto de desenfoque
    Rectangle {
        id: background
        anchors.fill: parent
        color: "transparent"
        layer.enabled: true
        layer.effect: FastBlur {
            radius: 32
            source: background
        }
    }

    // Contenedor principal
    Rectangle {
        id: container
        width: 600
        height: 180
        radius: 25
        color: "#1e1e1e"
        opacity: 0.9
        anchors.horizontalCenter: parent.horizontalCenter

        // Sombra suave
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 16
            samples: 32
            color: "#40000000"
        }

        RowLayout {
            anchors.fill: parent
            spacing: 20
            anchors.margins: 15

            // Área de la imagen del álbum
            Item {
                Layout.preferredWidth: 150
                Layout.preferredHeight: 150
                Layout.alignment: Qt.AlignVCenter

                Image {
                    id: img
                    source: image
                    width: parent.width
                    height: parent.height
                    fillMode: Image.PreserveAspectCrop
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: img.width
                            height: img.height
                            radius: 15
                        }
                    }
                }

                // Efecto de brillo en la imagen
                Rectangle {
                    anchors.fill: img
                    color: "transparent"
                    radius: 15
                    border.width: 2
                    border.color: "#60ffffff"
                }
            }

            // Área de texto y controles
            ColumnLayout {
                spacing: 10
                Layout.alignment: Qt.AlignVCenter

                // Nombre de la canción
                Text {
                    id: songName
                    text: name
                    font.pixelSize: 20
                    font.bold: true
                    color: "#ffffff"
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                // Nombre del artista
                Text {
                    id: artistName
                    text: artist
                    font.pixelSize: 14
                    color: "#b3b3b3"
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                // Controles de reproducción
                RowLayout {
                    spacing: 30
                    Layout.alignment: Qt.AlignHCenter

                    // Botón anterior
                    Button {
                        id: previousButton
                        implicitWidth: 40
                        implicitHeight: 40
                        onClicked: previous.running = true

                        background: Rectangle {
                            color: "transparent"
                            radius: 20
                        }

                        Image {
                            source: "previous.svg"
                            width: 24
                            height: 24
                            anchors.centerIn: parent
                        }

                        // Animación al hacer clic
                        Behavior on scale {
                            NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                        }
                        onPressed: scale = 0.9
                        onReleased: scale = 1.0
                    }

                    // Botón de play/pausa
                    Button {
                        id: playPauseButton
                        implicitWidth: 50
                        implicitHeight: 50
                        onClicked: tog.running = true

                        background: Rectangle {
                            color: "#ffffff"
                            radius: 25
                        }

                        Image {
                            source: "play-pause.svg"
                            width: 28
                            height: 28
                            anchors.centerIn: parent
                        }

                        // Animación al hacer clic
                        Behavior on scale {
                            NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                        }
                        onPressed: scale = 0.9
                        onReleased: scale = 1.0
                    }

                    // Botón siguiente
                    Button {
                        id: nextButton
                        implicitWidth: 40
                        implicitHeight: 40
                        onClicked: next.running = true

                        background: Rectangle {
                            color: "transparent"
                            radius: 20
                        }

                        Image {
                            source: "next.svg"
                            width: 24
                            height: 24
                            anchors.centerIn: parent
                        }

                        // Animación al hacer clic
                        Behavior on scale {
                            NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                        }
                        onPressed: scale = 0.9
                        onReleased: scale = 1.0
                    }
                }
            }
        }
    }
}
