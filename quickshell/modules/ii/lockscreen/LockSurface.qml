import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import qs
import "../../../services"
import "../../../modules/common/widgets" as Widgets
import "../../../modules/common/functions"
import "../../../GlobalStates.qml" as G
import "../background/widgets/battery"
import "../background/widgets/media"
import Quickshell

Item {
    id: root
    required property LockContext context

    property int blurRadius: 50
    property int blurSamples: 50
    property real fadeOutMul: 1
    property int animationDuration: 1200

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
                const hours = clock.date.getHours().toString().padStart(2, "0");
                const minutes = clock.date.getMinutes().toString().padStart(2, "0");
                return `${hours}:${minutes}`;
            }
        }

        ColumnLayout {
            y: 350
            anchors.horizontalCenter: parent.horizontalCenter
            BatteryContent {
                id: bat
                anchors.horizontalCenter: parent.horizontalCenter
                
                // Override colors for lockscreen visibility
                backgroundColor: "#80000000"
                ringBackgroundColor: "#40FFFFFF"
                textColor: "white"
                ringColorNormal: "white"
                ringColorCharging: "#2DCF59"
                ringColorLow: "#F2330D"
                ringColorMedium: "#FDD509"
                chargeIndicatorColor: "white"
                chargeIconColor: "black"
                
                shadowEnabled: false 
                
                // Añadir sombra manualmente si BatteryContent desactivó la suya interna
                // o confiar en el diseño actual. BatteryContent tiene sombra opcional.
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    radius: 16
                    samples: 32
                    color: "#40000000"
                }
            }
        }

        MediaContent {
            id: mediaControls
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.verticalCenter
                topMargin: 100
            }
        }

        Widgets.Toolbar {
            id: mainIsland
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 50
            }

            Loader {
                Layout.leftMargin: 10
                Layout.rightMargin: 6
                Layout.alignment: Qt.AlignVCenter
                active: root.context.fingerprintsConfigured || false
                visible: active

                sourceComponent: Widgets.MaterialSymbol {
                    text: "fingerprint"
                    iconSize: 24
                    color: strLoad.item.color7
                }
            }

            Widgets.ToolbarTextField {
                id: passwordBox
                Layout.rightMargin: -Layout.leftMargin
                placeholderText: G.screenUnlockFailed ? "Incorrect password" : "Enter password"

                focus: true
                clip: true
                font.pixelSize: 15
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

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: passwordBox.width - 8
                        height: passwordBox.height
                        radius: height / 2
                    }
                }

                property bool materialShapeChars: true
                color: ColorUtils.transparentize(strLoad.item.color7, materialShapeChars ? 1 : 0)
                
                PasswordChars {
                    visible: passwordBox.materialShapeChars
                    anchors {
                        fill: parent
                        leftMargin: passwordBox.padding
                        rightMargin: passwordBox.padding
                    }
                    length: root.context.currentText.length
                }

                Connections {
                    target: GlobalStates
                    function onScreenUnlockFailedChanged() {
                        if (G.screenUnlockFailed) wrongPasswordShakeAnim.restart();
                    }
                }
            }

            Widgets.ToolbarButton {
                id: confirmButton
                implicitWidth: height
                onClicked: root.context.tryUnlock()

                contentItem: Widgets.MaterialSymbol {
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
        iconColor: ColorUtils.isDark(strLoad.item.input_back) ? "white" : "black"
        menuBackgroundColor: strLoad.item.input_back
        menuTextColor: ColorUtils.isDark(strLoad.item.input_back) ? "white" : "black"
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
