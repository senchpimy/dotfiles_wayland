import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects

Item {
    id: root
    required property LockContext context

    property int blurRadius: 50
    property int blurSamples: 50
    property real fadeOutMul: 1
    property int animationDuration: 1200

    SequentialAnimation {
        id: shakeAnimation
        running: false

        NumberAnimation { target: passwordRow; property: "x"; to: -5; duration: 50; easing.type: Easing.InOutQuad }
        NumberAnimation { target: passwordRow; property: "x"; to: 5;  duration: 50; easing.type: Easing.InOutQuad }
        NumberAnimation { target: passwordRow; property: "x"; to: -3; duration: 50; easing.type: Easing.InOutQuad }
        NumberAnimation { target: passwordRow; property: "x"; to: 3;  duration: 50; easing.type: Easing.InOutQuad }
        NumberAnimation { target: passwordRow; property: "x"; to: 0;  duration: 50; easing.type: Easing.InOutQuad }
    }

    Item {
        id: mainContent
        anchors.fill: parent
        y: fadeOutMul * (height / 2 + childrenRect.height) // Desplazamiento vertical

        Loader {
            id: strLoad
            source: "ImagePath.qml"
        }

        Item {
            id: blurBase
            anchors.fill: parent
            
            Image {
                id: image
                source: strLoad.item.path
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                visible: false
            }

            GaussianBlur {
                anchors.fill: parent
                source: image
                radius: root.blurRadius
                samples: root.blurSamples
            }

            Rectangle {
                anchors.fill: parent
                color: "#20000000"
            }
        }

        Label {
            id: day
            property var date: new Date()

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 100
            }
            font.pointSize: 18
            font.family: "IBM Plex Sans Medium"
            font.bold: true
            color: strLoad.item.color0

            text: {
                const weekday = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
                const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                const day_n = weekday[day.date.getDay()];
                var date2 = day.date;
                date2.setHours(day.date.getHours() - 6);
                const date = date2.getUTCDate();
                const month = months[day.date.getMonth()];
                return `${day_n}, ${date} of ${month}`;
            }
        }

        Label {
            id: clock
            property var date: new Date()

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 120
            }

            renderType: Text.NativeRendering
            font.pointSize: 150
            font.family: "IBM Plex Sans Medium"
            color: strLoad.item.color7

            Timer {
                running: true
                repeat: true
                interval: 1000
                onTriggered: clock.date = new Date();
            }

            text: {
                const hours = clock.date.getHours().toString().padStart(2, '0');
                const minutes = clock.date.getMinutes().toString().padStart(2, '0');
                return `${hours}:${minutes}`;
            }
        }

        ColumnLayout {
            y: 350
            x: (parent.width / 2) - (75 * bat.total) - (13 * (bat.total > 1 ? bat.total : 0))
            Battery {
                id: bat
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        MediaControls {
            player: "spotify"
        }

        ColumnLayout {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 50
            }

            Huella {
                func: root.context
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 100
                }
            }

            RowLayout {
                id: passwordRow
                
                TextField {
                    id: passwordBox
                    implicitWidth: 250
                    padding: 10
                    focus: true
                    font.pointSize: 17
                    enabled: !root.context.unlockInProgress
                    echoMode: TextInput.Password
                    inputMethodHints: Qt.ImhSensitiveData
                    onTextChanged: {
                        root.context.currentText = this.text;
                        shakeAnimation.restart();
                    }
                    onAccepted: root.context.tryUnlock()
                    color: strLoad.item.color7
                    onCursorVisibleChanged: {
                        if (cursorVisible) cursorVisible = false;
                    }
                    cursorVisible: false

                    Connections {
                        target: root.context
                        function onCurrentTextChanged() {
                            passwordBox.text = root.context.currentText;
                        }
                    }

                    background: Rectangle {
                        color: strLoad.item.input_back
                        border.color: strLoad.item.color7
                        border.width: 5
                        radius: height / 2
                    }
                }
            }

            Label {
                visible: root.context.showFailure
                text: "Incorrect password"
            }
        }
    }

    Rectangle {
        id: darkenOverlay
        anchors.fill: parent
        color: "black"
        opacity: fadeOutMul
        visible: opacity > 0
    }

    SequentialAnimation {
        id: enterAnimation
        running: true
        
        NumberAnimation {
            target: root
            property: "fadeOutMul"
            from: 1
            to: 0
            duration: root.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    Connections {
        target: root.context
    }
}
