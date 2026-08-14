import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.modules.common
import qs.modules.common.widgets
import qs.services

ColumnLayout {
    id: root
    spacing: 15
    
    width: parent.width 

    property string currentTlpStatus: {
        if (!TlpProfiles.available) return qsTr("Cargando...")
        switch (TlpProfiles.profile) {
        case PowerProfile.PowerSaver: return qsTr("Ahorro")
        case PowerProfile.Performance: return qsTr("Rendimiento")
        case PowerProfile.Balanced: return qsTr("Balanceado")
        default: return qsTr("Cargando...")
        }
    }
    property int maxBrightness: 1
    property int currentBrightness: 0

    // Processes
    Process {
        id: kbdMaxBrightnessProcess
        running: false
        command: ["/home/plof/configs/tlp/keyboard_client.py", "max"]

        stdout: SplitParser {
            onRead: data => {
                let maxVal = parseInt(data.trim());
                if (!isNaN(maxVal) && maxVal > 0) {
                    root.maxBrightness = maxVal;
                }
            }
        }
    }

    Process {
        id: kbdSetBrightnessProcess
        running: false
        command: ["/home/plof/configs/tlp/keyboard_client.py", "set", root.currentBrightness.toString()]
    }

    Component.onCompleted: {
        kbdMaxBrightnessProcess.running = true;
    }

    // Header / Label
    StyledText {
        text: qsTr("Keyboard Brightness")
        font.pixelSize: Appearance.font.pixelSize.normal
        color: Appearance.colors.colOnLayer1
        Layout.leftMargin: 15
        Layout.topMargin: 10
    }

    // Using StyledSlider like QuickSliders.qml
    StyledSlider {
        id: kbdSlider
        Layout.fillWidth: true
        Layout.leftMargin: 15
        Layout.rightMargin: 15
        from: 0
        to: root.maxBrightness
        stepSize: 1
        snapMode: Slider.SnapAlways
        value: root.currentBrightness
        
        configuration: StyledSlider.Configuration.M

        onMoved: root.currentBrightness = value

        onPressedChanged: {
            if (!pressed) {
                kbdSetBrightnessProcess.running = true;
            }
        }

        MaterialSymbol {
            property bool nearFull: kbdSlider.value / kbdSlider.to >= 0.9
            anchors {
                verticalCenter: parent.verticalCenter
                right: nearFull ? kbdSlider.handle.right : parent.right
                rightMargin: nearFull ? 14 : 8
            }
            iconSize: 20
            color: nearFull ? Appearance.colors.colOnPrimary : Appearance.colors.colOnSecondaryContainer
            text: "keyboard"
            
            Behavior on anchors.rightMargin {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }
        }
    }

    // Status Text
    StyledText {
        Layout.fillWidth: true
        Layout.topMargin: 5
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Appearance.font.pixelSize.small
        color: Appearance.colors.colSubtext
        text: qsTr("Current State: <b>%1</b>").arg(root.currentTlpStatus)
        textFormat: Text.RichText
    }

    // Energy Mode Button using RippleButton
    RippleButton {
        id: tlpButton
        Layout.fillWidth: true
        Layout.leftMargin: 15
        Layout.rightMargin: 15
        Layout.preferredHeight: Appearance.sizes.barHeight
        
        onClicked: TlpProfiles.cycle()

        scale: tlpButton.down ? 0.95 : 1
        Behavior on scale {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }

        contentItem: RowLayout {
            spacing: 10
            MaterialSymbol {
                text: "bolt"
                color: Appearance.colors.colOnLayer1
            }
            StyledText {
                text: qsTr("Switch Energy Mode")
                color: Appearance.colors.colOnLayer1
                Layout.fillWidth: true
            }
        }
        
        Rectangle {
            anchors.fill: parent
            z: -1
            radius: Appearance.rounding.small
            color: tlpButton.pressed ? Appearance.colors.colLayer2 : Appearance.colors.colLayer1
            border.color: Appearance.colors.colOutlineVariant
            border.width: 1
        }
    }
    
    Item {
        Layout.fillHeight: true
    }
}