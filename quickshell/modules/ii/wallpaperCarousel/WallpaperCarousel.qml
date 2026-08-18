import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

// Wallpaper/theme picker that replaces rofi's awwwallselect/themeselect with
// pibble's parallax carousel. One window, two modes:
//   - "walls"  : the active HyDE theme's wallpapers -> awwwallpaper.sh -s
//   - "themes" : the HyDE themes (cover = wall.set) -> themeswitch.sh -s
// Data comes from scripts/hyprland/wallpaper_carousel.sh; no thumbnails are
// generated (HyDE's .sqre/.quad are rofi-only) - the carousel shows the raw
// images directly.
Scope {
    id: root

    property var focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name)

    property string mode: "walls"
    property var items: []
    property string current: ""

    readonly property string scriptPath: FileUtils.trimFileProtocol(Quickshell.shellPath("scripts/hyprland/wallpaper_carousel.sh"))
    readonly property string hydeBin: Quickshell.env("HOME") + "/.local/share/bin"

    function open(m) {
        mode = m;
        GlobalStates.wallpaperCarouselOpen = true;
        dataProc.running = false;
        Qt.callLater(() => {
            dataProc.running = true;
            carousel.restartEntrance();
        });
    }

    function close() {
        GlobalStates.wallpaperCarouselOpen = false;
    }

    function toggle(m) {
        if (GlobalStates.wallpaperCarouselOpen && root.mode === m)
            close();
        else
            open(m);
    }

    function apply(payload) {
        const script = root.mode === "themes" ? hydeBin + "/themeswitch.sh" : hydeBin + "/awwwallpaper.sh";
        close();
        Quickshell.execDetached(["bash", "-c", `exec "$1" -s "$2"`, "_", script, payload]);
    }

    Process {
        id: dataProc
        command: ["bash", root.scriptPath, root.mode]
        stdout: StdioCollector {
            onStreamFinished: {
                let parsed;
                try {
                    parsed = JSON.parse(text);
                } catch (e) {
                    parsed = { items: [], current: "" };
                }
                root.items = parsed.items ?? [];
                root.current = parsed.current ?? "";
                const idx = root.items.findIndex(it => it.image === root.current || it.payload === root.current);
                carousel.jumpTo(idx >= 0 ? idx : 0);
            }
        }
    }

    GlobalShortcut {
        name: "wallpaperCarouselToggle"
        description: "Toggles the wallpaper carousel (same theme)"

        onPressed: root.toggle("walls")
    }

    GlobalShortcut {
        name: "themeCarouselToggle"
        description: "Toggles the theme carousel"

        onPressed: root.toggle("themes")
    }

    PanelWindow {
        id: panel
        visible: GlobalStates.wallpaperCarouselOpen
        screen: root.focusedScreen
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "quickshell:wallpaperCarousel"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        Rectangle {
            id: scrim
            anchors.fill: parent
            color: ColorUtils.transparentize(Appearance.m3colors.m3background, Appearance.m3colors.darkmode ? 0.35 : 0.5)

            MouseArea {
                anchors.fill: parent
                onClicked: root.close()
            }
        }

        Item {
            anchors.centerIn: parent
            width: carousel.width
            height: carousel.height

            // Swallow clicks inside the carousel bounds so they never reach
            // the scrim's close-on-click MouseArea below.
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onClicked: {}
            }

            ParallaxCarousel {
                id: carousel
                anchors.centerIn: parent
                items: root.items
                active: GlobalStates.wallpaperCarouselOpen
                onActivated: root.apply(payload)
                onDismissed: root.close()
            }
        }

        StyledText {
            anchors.centerIn: parent
            visible: root.items.length === 0 && GlobalStates.wallpaperCarouselOpen
            text: root.mode === "themes" ? "No themes found" : "No wallpapers found"
            font.pixelSize: Appearance.font.pixelSize.large
        }
    }
}
