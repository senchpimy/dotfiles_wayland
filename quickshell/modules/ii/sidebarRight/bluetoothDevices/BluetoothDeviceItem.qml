import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

DialogListItem {
    id: root
    required property var device
    property bool expanded: false
    pointingHandCursor: !expanded

    onClicked: expanded = !expanded
    altAction: () => expanded = !expanded
    
    component ActionButton: DialogButton {
        colBackground: Appearance.colors.colPrimary
        colBackgroundHover: Appearance.colors.colPrimaryHover
        colRipple: Appearance.colors.colPrimaryActive
        colText: Appearance.colors.colOnPrimary
    }

    contentItem: ColumnLayout {
        anchors {
            fill: parent
            topMargin: root.verticalPadding
            leftMargin: root.horizontalPadding
            rightMargin: root.horizontalPadding
        }
        spacing: 0

        RowLayout {
            // Name
            spacing: 10

            MaterialSymbol {
                iconSize: Appearance.font.pixelSize.larger
                text: Icons.getBluetoothDeviceMaterialSymbol(root.device?.icon || "")
                color: Appearance.colors.colOnSurfaceVariant
            }

            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                StyledText {
                    Layout.fillWidth: true
                    color: Appearance.colors.colOnSurfaceVariant
                    elide: Text.ElideRight
                    text: root.device?.name || Translation.tr("Unknown device")
                }
                StyledText {
                    visible: (root.device?.connected || root.device?.paired) ?? false
                    Layout.fillWidth: true
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                    elide: Text.ElideRight
                    text: {
                        if (!root.device?.paired) return "";
                        let statusText = root.device?.connected ? Translation.tr("Connected") : Translation.tr("Paired");
                        if (!root.device?.batteryAvailable) return statusText;
                        statusText += ` • ${Math.round(root.device?.battery * 100)}%`;
                        return statusText;
                    }
                }
            }

            MaterialSymbol {
                text: "keyboard_arrow_down"
                iconSize: Appearance.font.pixelSize.larger
                color: Appearance.colors.colOnLayer3
                rotation: root.expanded ? 180 : 0
                Behavior on rotation {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
            }
        }

        RowLayout {
            visible: root.expanded
            Layout.topMargin: 8
            Item {
                Layout.fillWidth: true
            }
            ActionButton {
                buttonText: root.device?.connected ? Translation.tr("Disconnect") : Translation.tr("Connect")

                onClicked: {
                    if (root.device?.connected) {
                        root.device.disconnect();
                    } else {
                        root.device.connect();
                    }
                }
            }
            ActionButton {
                visible: root.device?.paired ?? false
                colBackground: Appearance.colors.colError
                colBackgroundHover: Appearance.colors.colErrorHover
                colRipple: Appearance.colors.colErrorActive
                colText: Appearance.colors.colOnError

                buttonText: Translation.tr("Forget")
                onClicked: {
                    root.device?.forget();
                }
            }
        }

        // Audio Profile Selector
        ColumnLayout {
            id: audioProfileSection
            Layout.fillWidth: true
            Layout.topMargin: 12
            Layout.bottomMargin: 8
            spacing: 4
            
            readonly property string deviceMac: AudioProfiles.getMacFromDevice(root.device)
            readonly property var deviceData: AudioProfiles.deviceProfiles[deviceMac]
            
            visible: root.expanded && root.device?.connected && deviceMac !== ""

            StyledText {
                text: audioProfileSection.deviceData ? Translation.tr("Audio Profile") : Translation.tr("Looking for profiles...")
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colSubtext
                Layout.leftMargin: 4
            }

            Repeater {
                id: profileRepeater
                model: audioProfileSection.deviceData?.profiles || []
                
                delegate: DialogListItem {
                    id: profileItem
                    Layout.fillWidth: true
                    height: 36
                    horizontalPadding: 8
                    verticalPadding: 4
                    
                    readonly property var profile: modelData
                    readonly property bool active: audioProfileSection.deviceData?.activeProfile === profile.name

                    contentItem: RowLayout {
                        anchors.fill: parent
                        spacing: 12
                        
                        MaterialSymbol {
                            text: profileItem.active ? "radio_button_checked" : "radio_button_unchecked"
                            iconSize: Appearance.font.pixelSize.base
                            color: profileItem.active ? Appearance.colors.colPrimary : Appearance.colors.colOnSurfaceVariant
                        }
                        
                        StyledText {
                            text: profile.description
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            color: profileItem.active ? Appearance.colors.colPrimary : Appearance.colors.colOnSurfaceVariant
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }
                    
                    onClicked: {
                        AudioProfiles.setProfile(audioProfileSection.deviceData.index, profile.name);
                    }
                }
            }
        }
        Item {
            Layout.fillHeight: true
        }
    }
}
