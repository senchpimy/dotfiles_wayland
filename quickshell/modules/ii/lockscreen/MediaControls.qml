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
    readonly property string imageBasePath: "file://" + Quickshell.shellPath("assets/lockscreen/image.jpg")

    readonly property var test: Process {
        running: true
        command: ["playerctl", "-l"]
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
    }

    readonly property var next: Process {
        command: ["playerctl", "next", "-p", player]
    }

    readonly property var previous: Process {
        command: ["playerctl", "previous", "-p", player]
    }

    readonly property var artistP: Process {
        running: true
        command: ["playerctl", "metadata", "artist", "-p", player]
        stdout: SplitParser {
            onRead: data => {
                artist = data
            }
        }
    }

    readonly property var nameP: Process {
        running: true
        command: ["playerctl", "metadata", "title", "-p", player]
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
        command: ["python", Quickshell.shellPath("scripts/lockscreen/artista.py"), player]
        stdout: SplitParser {
            onRead: data => {
                imageVersion++
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

                    Text {
                        anchors {
                            top: parent.top
                            topMargin: -80
                        }
                        text: name
                        font.pointSize: 21
                        font.bold: true
                        color: "#E0E4DB"
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
                            focusPolicy: Qt.NoFocus
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
                                source: "file://" + Quickshell.shellPath("assets/lockscreen/previous.svg")
                                anchors.centerIn: parent
                                fillMode: Image.PreserveAspectFit
                            }

                            PropertyAnimation {
                                id: pAnimation
                                target: p
                                property: "scale"
                                to: 0.8
                                duration: 100
                                easing.type: Easing.InOutQuad
                            }
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
                            focusPolicy: Qt.NoFocus
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
                                source: "file://" + Quickshell.shellPath("assets/lockscreen/play-pause.svg")
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
                            focusPolicy: Qt.NoFocus
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
                                source: "file://" + Quickshell.shellPath("assets/lockscreen/next.svg")
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
