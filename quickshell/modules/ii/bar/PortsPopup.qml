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

Scope {
    id: root
    
    readonly property real widgetWidth: 400
    readonly property real widgetHeight: 500
    property real popupRounding: Appearance.rounding.screenRounding - Appearance.sizes.hyprlandGapsOut + 1

    Loader {
        id: portsLoader
        active: GlobalStates.portsOpen
        
        sourceComponent: PanelWindow {
            id: popupWindow
            visible: true
            color: "transparent"
            
            property var cursorScreen: {
                var focusedName = Hyprland.focusedMonitor?.name;
                var screens = Quickshell.screens;
                if (focusedName && screens) {
                    for (var i=0; i<screens.length; i++) {
                        if (screens[i].name === focusedName) return screens[i];
                    }
                }
                return (screens && screens.length > 0) ? screens[0] : null;
            }

            screen: cursorScreen
            
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            WlrLayershell.namespace: "quickshell:portsPopup"
            WlrLayershell.layer: WlrLayer.Overlay

            anchors {
                top: !Config.options.bar.bottom || Config.options.bar.vertical
                bottom: Config.options.bar.bottom && !Config.options.bar.vertical
                left: !(Config.options.bar.vertical && Config.options.bar.bottom)
                right: Config.options.bar.vertical && Config.options.bar.bottom
            }

            margins {
                top: Config.options.bar.vertical ? ((popupWindow.screen.height / 2) - root.widgetHeight / 2) : Appearance.sizes.barHeight
                bottom: Appearance.sizes.barHeight
                left: Config.options.bar.vertical ? Appearance.sizes.barHeight : ((popupWindow.screen.width / 2) - (root.widgetWidth / 2))
                right: Appearance.sizes.barHeight
            }
            
            implicitWidth: root.widgetWidth
            implicitHeight: root.widgetHeight

            mask: Region {
                item: portsContent
            }

            HyprlandFocusGrab {
                windows: [popupWindow]
                active: portsLoader.active
                onCleared: () => {
                    if (!active) {
                        GlobalStates.portsOpen = false;
                    }
                }
            }
            
            PortsPopupContent {
                id: portsContent
                anchors.fill: parent
                popupRounding: root.popupRounding
            }
        }
    }
}
