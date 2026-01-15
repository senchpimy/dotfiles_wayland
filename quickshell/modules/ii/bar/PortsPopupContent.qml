pragma ComponentBehavior: Bound
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: root
    
    readonly property real widgetWidth: 400
    readonly property real widgetHeight: 500
    property real popupRounding: Appearance.rounding.small
    
    property var portsData: []

    implicitWidth: widgetWidth
    implicitHeight: widgetHeight

    Process {
        id: portsProc
        command: [Directories.scriptPath + "/get_ports.py"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    root.portsData = JSON.parse(data);
                } catch (e) {
                    console.error("Failed to parse ports data: " + e)
                }
            }
        }
    }

    Timer {
        id: updateTimer
        interval: 2000
        running: GlobalStates.portsOpen
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            portsProc.running = false
            portsProc.running = true
        }
    }

    StyledRectangularShadow {
        anchors.fill: mainContainer
        target: mainContainer
    }

    Rectangle {
        id: mainContainer
        anchors {
            fill: parent
            margins: Appearance.sizes.elevationMargin
        }
        color: Appearance.m3colors.m3surfaceContainer
        radius: root.popupRounding
        clip: true
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                MaterialSymbol {
                    text: "lan"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer0
                }
                StyledText {
                    text: "Open TCP Ports"
                    font.bold: true
                    font.pixelSize: Appearance.font.pixelSize.large
                    Layout.fillWidth: true
                }
                
                CircleUtilButton {
                    implicitWidth: 30
                    implicitHeight: 30
                    onClicked: {
                        portsProc.running = false
                        portsProc.running = true
                    }
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "refresh"
                        iconSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colOnLayer0
                    }
                }

                CircleUtilButton {
                    implicitWidth: 30
                    implicitHeight: 30
                    onClicked: GlobalStates.portsOpen = false
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "close"
                        iconSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colOnLayer0
                    }
                }
            }

            ListView {
                id: portsList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: root.portsData
                spacing: 4

                delegate: Rectangle {
                    required property var modelData
                    width: portsList.width
                    height: 40
                    color: Appearance.colors.colLayer1
                    radius: Appearance.rounding.small
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 10
                        
                        StyledText {
                            text: modelData.port
                            font.bold: true
                            color: Appearance.m3colors.m3primary
                            Layout.preferredWidth: 50
                        }
                        
                        StyledText {
                            text: modelData.protocol.toUpperCase()
                            color: Appearance.colors.colSubtext
                            font.pixelSize: Appearance.font.pixelSize.small
                            Layout.preferredWidth: 40
                        }
                        
                        StyledText {
                            text: modelData.process
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        
                        StyledText {
                            text: modelData.pid === -1 ? "-" : modelData.pid
                            color: Appearance.colors.colSubtext
                            font.pixelSize: Appearance.font.pixelSize.small
                            Layout.preferredWidth: 50
                            horizontalAlignment: Text.AlignRight
                        }
                        
                        Rectangle {
                            width: 30
                            height: 30
                            radius: 15
                            color: killMouseArea.containsMouse ? "#ff5555" : "transparent"
                            visible: modelData.pid !== -1
                            
                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: "close"
                                iconSize: Appearance.font.pixelSize.normal
                                color: killMouseArea.containsMouse ? "white" : Appearance.colors.colOnLayer0
                            }
                            
                            MouseArea {
                                id: killMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    Quickshell.execDetached(["kill", modelData.pid.toString()])
                                    refreshTimer.start()
                                }
                            }
                        }
                    }
                }
                
                Timer {
                    id: refreshTimer
                    interval: 500
                    onTriggered: {
                        portsProc.running = false
                        portsProc.running = true
                    }
                }
            }
        }
    }
}
