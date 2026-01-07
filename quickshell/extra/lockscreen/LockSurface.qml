import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import qs
import "../../services"
import "../../modules"
import "../../modules/common/widgets"
import "../../modules/common/functions"
import PasswordChars
import Quickshell

Item {
    id: root
    required property LockContext context

    property int blurRadius: 50
    property int blurSamples: 50
    property real fadeOutMul: 1
    property int animationDuration: 1200

    // Shake when wrong password (from example)
    SequentialAnimation {
        id: wrongPasswordShakeAnim
        NumberAnimation { target: passwordBox; property: "Layout.leftMargin"; to: -30; duration: 50 }
        NumberAnimation { target: passwordBox; property: "Layout.leftMargin"; to: 30; duration: 50 }
        NumberAnimation { target: passwordBox; property: "Layout.leftMargin"; to: -15; duration: 40 }
        NumberAnimation { target: passwordBox; property: "Layout.leftMargin"; to: 15; duration: 40 }
        NumberAnimation { target: passwordBox; property: "Layout.leftMargin"; to: 0; duration: 30 }
    }

    Item {
        id: mainContent
        anchors.fill: parent
        y: fadeOutMul * (height / 2 + childrenRect.height)

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
            id: papu
            player: "spotify"
        }

        // --- PASSWORD BAR (STYLE FROM EJEMPLO) ---
        Toolbar {
            id: mainIsland
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 50
            }

            // Optional Fingerprint icon from example
            Loader {
                Layout.leftMargin: 10
                Layout.rightMargin: 6
                Layout.alignment: Qt.AlignVCenter
                active: root.context.fingerprintsConfigured || false
                visible: active

                sourceComponent: MaterialSymbol {
                    text: "fingerprint"
                    iconSize: 24
                    color: strLoad.item.color7
                }
            }

            ToolbarTextField {
                id: passwordBox
                Layout.rightMargin: -Layout.leftMargin
                placeholderText: GlobalStates.screenUnlockFailed ? "Incorrect password" : "Enter password"

                focus: true
                clip: true
                enabled: !root.context.unlockInProgress
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData

                onTextChanged: {
                    root.context.currentText = this.text;
                }
                onAccepted: root.context.tryUnlock()

                Connections {
                    target: root.context
                    function onCurrentTextChanged() {
                        passwordBox.text = root.context.currentText;
                    }
                }

                // Custom dots logic from example
                property bool materialShapeChars: true
                color: ColorUtils.transparentize(strLoad.item.color7, materialShapeChars ? 0 : 1)
                
                Loader {
                    active: passwordBox.materialShapeChars
                    anchors {
                        fill: parent
                        leftMargin: passwordBox.padding
                        rightMargin: passwordBox.padding
                    }
                    sourceComponent: PasswordChars {
                        length: root.context.currentText.length
                    }
                }

                Connections {
                    target: GlobalStates
                    function onScreenUnlockFailedChanged() {
                        if (GlobalStates.screenUnlockFailed) wrongPasswordShakeAnim.restart();
                    }
                }
            }

            ToolbarButton {
                id: confirmButton
                implicitWidth: height
                onClicked: root.context.tryUnlock()

                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    iconSize: 24
                    text: "arrow_right_alt"
                    color: strLoad.item.color7
                }
            }
        }

        Huella {
            func: root.context
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: mainIsland.top
                bottomMargin: 20
            }
        }
    }

    Power {
        id: powerMenu
        anchors {
            bottom: root.bottom
            right: root.right
            rightMargin: 100
            bottomMargin: 50
        }
        iconColor: strLoad.item.color7
        menuBackgroundColor: strLoad.item.input_back
        menuTextColor: strLoad.item.color7
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
}
