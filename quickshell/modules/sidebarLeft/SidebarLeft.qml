import "root:/"
import "root:/services"
import "root:/modules/common"
import "root:/modules/common/widgets"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland

Scope { // Scope
    id: root

    property string currentTlpStatus: qsTr("Cargando...")

    Process {
         id: tlpSwitchProcess
         running: false
         command: ["/home/plof/configs/tlp/client.py", "--switch"]
         onRunningChanged: {
             if (!running) {
                 tlpStatusProcess.running = true;
             }
         }
    }

    Process {
        id: tlpStatusProcess
        running: false
        command: ["/home/plof/configs/tlp/client.py"]
        stdout: SplitParser {
            onRead: data => {
                root.currentTlpStatus = data;
                //console.log("TlpSwitcher recibió nuevo estado: '" + tlpButton.tlpStatus + "'");
            }
        }
    }

    property int sidebarPadding: 15
    property bool detach: false
    property Component contentComponent: SidebarLeftContent {}
    property Item sidebarContent

    Component.onCompleted: {
        root.sidebarContent = contentComponent.createObject(null, {
            "scopeRoot": root,
        });
        sidebarLoader.item.contentParent.children = [root.sidebarContent];
        tlpStatusProcess.running = true;
    }

    onDetachChanged: {
        if (root.detach) {
            sidebarContent.parent = null; // Detach content from sidebar
            sidebarLoader.active = false; // Unload sidebar
            detachedSidebarLoader.active = true; // Load detached window
            detachedSidebarLoader.item.contentParent.children = [sidebarContent];
        } else {
            sidebarContent.parent = null; // Detach content from window
            detachedSidebarLoader.active = false; // Unload detached window
            sidebarLoader.active = true; // Load sidebar
            sidebarLoader.item.contentParent.children = [sidebarContent];
        }
    }

    Loader {
        id: sidebarLoader
        active: true
        
        sourceComponent: PanelWindow { // Window
            id: sidebarRoot
            visible: GlobalStates.sidebarLeftOpen
            
            property bool extend: false
            property real sidebarWidth: sidebarRoot.extend ? Appearance.sizes.sidebarWidthExtended : Appearance.sizes.sidebarWidth
            property var contentParent: dynamicContentParent

            function hide() {
                GlobalStates.sidebarLeftOpen = false
            }

            exclusiveZone: 0
            implicitWidth: Appearance.sizes.sidebarWidthExtended + Appearance.sizes.elevationMargin
            WlrLayershell.namespace: "quickshell:sidebarLeft"
            // Hyprland 0.49: OnDemand is Exclusive, Exclusive just breaks click-outside-to-close
            // WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            color: "transparent"

            anchors {
                top: true
                left: true
                bottom: true
            }

            mask: Region {
                item: sidebarLeftBackground
            }

            HyprlandFocusGrab { // Click outside to close
                id: grab
                windows: [ sidebarRoot ]
                active: sidebarRoot.visible
                onActiveChanged: { // Focus the selected tab
                    //if (active) sidebarLeftBackground.children[0].focusActiveItem()
                }
                onCleared: () => {
                    if (!active) sidebarRoot.hide()
                }
            }

            // Content
            StyledRectangularShadow {
                target: sidebarLeftBackground
                radius: sidebarLeftBackground.radius
            }
            Rectangle {
                id: sidebarLeftBackground
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: Appearance.sizes.hyprlandGapsOut
                anchors.leftMargin: Appearance.sizes.hyprlandGapsOut
                width: sidebarRoot.sidebarWidth - Appearance.sizes.hyprlandGapsOut - Appearance.sizes.elevationMargin
                height: parent.height - Appearance.sizes.hyprlandGapsOut * 2
                color: Appearance.colors.colLayer0
                radius: Appearance.rounding.screenRounding - Appearance.sizes.hyprlandGapsOut + 1

                Behavior on width {
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        sidebarRoot.hide();
                    }
                    if (event.modifiers === Qt.ControlModifier) {
                        if (event.key === Qt.Key_O) {
                            sidebarRoot.extend = !sidebarRoot.extend;
                        }
                        else if (event.key === Qt.Key_P) {
                            root.detach = !root.detach;
                        }
                        event.accepted = true;
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: root.sidebarPadding
                    spacing: 15 // Un poco más de espacio para la nueva etiqueta

                    Item {
                        id: dynamicContentParent
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Appearance.font.family.main
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colSubtext
                        text: qsTr("Estado actual: <b>%1</b>").arg(root.currentTlpStatus)
                        textFormat: Text.RichText
                    }

                    Button {
                        id: tlpButton
                        text: qsTr("Cambiar Modo de Energía")
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        implicitHeight: Appearance.sizes.barHeight

                        onClicked: {
                            tlpSwitchProcess.running = true;
                        }

                        background: Rectangle {
                            radius: Appearance.rounding.small
                            color: tlpButton.pressed ? Appearance.colors.colPrimaryActive
                                 : (tlpButton.hovered ? Appearance.colors.colPrimary 
                                 : Appearance.colors.colLayer1)
                            border.color: Appearance.colors.colOutlineVariant
                            border.width: 1
                            Behavior on color {
                                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                            }
                        }

                        contentItem: Text {
                            text: tlpButton.text
                            font: Appearance.font.family.main
                            color: tlpButton.hovered || tlpButton.pressed 
                                   ? Appearance.colors.colOnPrimary 
                                   : Appearance.colors.colOnLayer2
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }


    Loader {
        id: detachedSidebarLoader
        active: false

        sourceComponent: FloatingWindow {
            id: detachedSidebarRoot
            visible: GlobalStates.sidebarLeftOpen
            property var contentParent: detachedDynamicContentParent 
            
            Rectangle{
                id: detachedSidebarBackground
                anchors.fill: parent
                color: Appearance.colors.colLayer0

                Keys.onPressed: (event) => {
                    if (event.modifiers === Qt.ControlModifier) {
                        if (event.key === Qt.Key_P) {
                            root.detach = !root.detach;
                        }
                        event.accepted = true;
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: root.sidebarPadding
                    spacing: 15

                    Item {
                        id: detachedDynamicContentParent
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Appearance.font.family.main
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colSubtext
                        text: qsTr("Estado actual: <b>%1</b>").arg(root.currentTlpStatus)
                        textFormat: Text.RichText
                    }
                    
                    Button {
                        id: detachedTlpButton
                        text: qsTr("Cambiar Modo de Energía")
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        implicitHeight: Appearance.sizes.barHeight

                        onClicked: {
                            tlpSwitchProcess.running = true;
                        }

                        background: Rectangle {
                            radius: Appearance.rounding.small
                            color: detachedTlpButton.pressed ? Appearance.colors.colPrimaryActive
                                 : (detachedTlpButton.hovered ? Appearance.colors.colPrimary 
                                 : Appearance.colors.colLayer1)
                            border.color: Appearance.colors.colOutlineVariant
                            border.width: 1
                            Behavior on color {
                                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                            }
                        }

                        contentItem: Text {
                            text: detachedTlpButton.text
                            font: Appearance.font.family.main
                            color: detachedTlpButton.hovered || detachedTlpButton.pressed 
                                   ? Appearance.colors.colOnPrimary 
                                   : Appearance.colors.colOnLayer2
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "sidebarLeft"

        function toggle(): void {
            GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen
        }

        function close(): void {
            GlobalStates.sidebarLeftOpen = false
        }

        function open(): void {
            GlobalStates.sidebarLeftOpen = true
        }
    }

    GlobalShortcut {
        name: "sidebarLeftToggle"
        description: qsTr("Toggles left sidebar on press")

        onPressed: {
            GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen;
        }
    }

    GlobalShortcut {
        name: "sidebarLeftOpen"
        description: qsTr("Opens left sidebar on press")

        onPressed: {
            GlobalStates.sidebarLeftOpen = true;
        }
    }

    GlobalShortcut {
        name: "sidebarLeftClose"
        description: qsTr("Closes left sidebar on press")

        onPressed: {
            GlobalStates.sidebarLeftOpen = false;
        }
    }

    GlobalShortcut {
        name: "sidebarLeftToggleDetach"
        description: qsTr("Detach left sidebar into a window/Attach it back")

        onPressed: {
            root.detach = !root.detach;
        }
    }

}
