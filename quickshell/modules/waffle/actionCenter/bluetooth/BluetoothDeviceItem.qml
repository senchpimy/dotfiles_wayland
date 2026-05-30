import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs
import qs.services
import qs.services.network
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.waffle.looks
import qs.modules.waffle.actionCenter

ExpandableChoiceButton {
    id: root
    required property BluetoothDevice device

    contentItem: RowLayout {
        id: contentItem
        spacing: 20

        // Device icon
        FluentIcon {
            Layout.topMargin: 4
            Layout.bottomMargin: 4
            Layout.alignment: Qt.AlignTop
            icon: WIcons.bluetoothDeviceIcon(root?.device)
            implicitSize: 18
        }

        ColumnLayout {
            Layout.topMargin: 4
            Layout.bottomMargin: 4
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            spacing: 0

            WText {
                // Network name
                Layout.fillWidth: true
                elide: Text.ElideRight
                font.pixelSize: Looks.font.pixelSize.large
                text: root.device?.name || Translation.tr("Unknown device")
            }
            WText { // Status
                id: statusText
                Layout.fillWidth: true
                elide: Text.ElideRight
                font.pixelSize: Looks.font.pixelSize.large
                color: Looks.colors.subfg
                visible: root.device?.connected || root.expanded
                Behavior on opacity {
                    animation: Looks.transition.opacity.createObject(this)
                }
                text: {
                    if (!root.device?.paired)
                        return Translation.tr("Not connected");
                    let statusText = root.device?.connected ? Translation.tr("Connected") : Translation.tr("Paired");
                    if (!root.device?.batteryAvailable)
                        return statusText;
                    statusText += ` • ${Math.round(root.device?.battery * 100)}%`;
                    return statusText;
                }
            }

            WButton {
                Layout.alignment: Qt.AlignRight
                horizontalAlignment: Text.AlignHCenter
                visible: root.expanded
                checked: !(root.device?.connected ?? false)
                colBackground: Looks.colors.bg2
                colBackgroundHover: Looks.colors.bg2Hover
                colBackgroundActive: Looks.colors.bg2Active
                implicitHeight: 30
                implicitWidth: 148
                text: root.device?.connected ? Translation.tr("Disconnect") : Translation.tr("Connect")

                onClicked: {
                    if (root.device?.connected) {
                        root.device.disconnect();
                    } else {
                        root.device.connect();
                    }
                }
            }

            // Audio Profile Selector
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 12
                spacing: 6
                visible: root.expanded && root.device?.connected && 
                         (AudioProfiles.deviceProfiles[root.device?.address?.toUpperCase().replaceAll("-", ":")] !== undefined)

                WText {
                    text: Translation.tr("Audio Profile")
                    font.pixelSize: Looks.font.pixelSize.base
                    color: Looks.colors.subfg
                    Layout.leftMargin: 4
                }

                Repeater {
                    model: AudioProfiles.deviceProfiles[root.device?.address?.toUpperCase().replaceAll("-", ":")]?.profiles || []
                    
                    delegate: WButton {
                        Layout.fillWidth: true
                        implicitHeight: 32
                        text: modelData.description
                        horizontalAlignment: Text.AlignLeft
                        Layout.leftMargin: 4
                        
                        readonly property bool active: AudioProfiles.deviceProfiles[root.device?.address?.toUpperCase().replaceAll("-", ":")]?.activeProfile === modelData.name
                        
                        colBackground: active ? Looks.colors.accent : Looks.colors.bg2
                        colBackgroundHover: active ? Looks.colors.accentHover : Looks.colors.bg2Hover
                        colForeground: active ? Looks.colors.onAccent : Looks.colors.fg

                        onClicked: {
                            const cardData = AudioProfiles.deviceProfiles[root.device?.address?.toUpperCase().replaceAll("-", ":")];
                            AudioProfiles.setProfile(cardData.index, modelData.name);
                        }
                    }
                }
            }
        }
    }
}
