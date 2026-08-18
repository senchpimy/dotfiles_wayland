import QtQuick
import QtMultimedia

// One MediaPlayer per video wallpaper, opened once and kept open for the life
// of the process, with only the one being looked at ever unpaused. Ported from
// pibble's WallpaperVideoPool (launcher/WallpaperVideoPool.qml) for the reusable
// carousel: `paths` replaces pibble's read of the Wallpapers service, and a
// failed open is reported with a console.warn rather than a notifier.
//
// Opening a video file costs ~600ms of backend init the first time in a process
// and ~80ms every time after, all on the GUI thread. Nothing here is ever
// destroyed or re-sourced: navigation only moves `current` and toggles `live`,
// and the file opens happen in the warm pass below while the carousel is closed.
Item {
    id: root

    // Path of the video whose surface shows, "" for none. Opened on the spot if
    // the warm pass hasn't reached it yet - one stall on first sight of a file
    // rather than one per visit.
    property string current: ""
    // Whether `current` runs. Everything else sits paused on frame 0, which is
    // the frame a paused player decodes on first sync (see Component.onCompleted),
    // so a surface can stay up through a fade-out with nothing to give the swap
    // away.
    property bool live: false
    // Where the video surface sits inside this item. Not simply the item's own
    // bounds: the carousel's windows are a narrow frame onto a wider image that
    // pans with the strip, so its surface is wider than the item and moves
    // within it.
    property real surfaceX: 0
    property real surfaceY: 0
    property real surfaceWidth: root.width
    property real surfaceHeight: root.height
    // Opens one more file per tick while true. The owner keeps this off
    // whenever the carousel is on screen: an open is ~80ms of GUI thread, so it
    // has to land somewhere nobody is looking.
    property bool warming: false
    // Every video path the owner knows about (the .mp4 items' image fields).
    property var paths: []

    // Paths that have a player, in the order they were opened. Appended to in
    // place: a var property holding a JS array deliberately doesn't notify on
    // mutation, which is what keeps each delegate's `path` below from
    // re-evaluating (and its player from reopening the file) every time another
    // entry joins. openCount is the Repeater's model, so bumping it after the
    // push is what actually builds the new player.
    property var openPaths: []
    property int openCount: 0

    function open(path) {
        if (!path || root.openPaths.indexOf(path) >= 0)
            return;
        root.openPaths.push(path);
        root.openCount = root.openPaths.length;
    }
    onCurrentChanged: root.open(root.current)

    Timer {
        // One file per tick rather than one per frame: an open costs an order
        // of magnitude more than a decode, so it needs the gaps to stay off the
        // render loop's back.
        interval: 250
        repeat: true
        running: root.warming && root.openCount < root.paths.length
        onTriggered: root.open(root.paths.find(p => root.openPaths.indexOf(p) < 0) ?? "")
    }

    Repeater {
        model: root.openCount

        VideoOutput {
            id: surface
            required property int index
            // Read once, as this delegate is built: openPaths is only ever
            // appended to in place (see above), so the binding has nothing to
            // re-evaluate on and the player below never has its source
            // rewritten out from under it.
            readonly property string path: root.openPaths[index]
            readonly property bool showing: root.current === surface.path

            x: root.surfaceX
            y: root.surfaceY
            width: root.surfaceWidth
            height: root.surfaceHeight
            fillMode: VideoOutput.PreserveAspectCrop
            visible: surface.showing

            // Rewound rather than resumed, since the frame this takes over from
            // is frame 0 - picking up mid-clip would make the handover jump.
            // Seeking, pausing and starting a player that already has its file
            // open are all free; only the open itself isn't.
            function sync() {
                if (surface.showing && root.live) {
                    player.position = 0;
                    player.play();
                } else if (player.playbackState !== MediaPlayer.PausedState) {
                    player.pause();
                }
            }
            onShowingChanged: surface.sync()
            // pause() on a player that has never run is what decodes its first
            // frame, so a pooled player already holds a frame ready to show by
            // the time anything navigates to it.
            Component.onCompleted: surface.sync()
            // one sync per player when the carousel comes and goes, rather than
            // per player per navigation: `live` only moves when the carousel does
            Connections {
                target: root
                function onLiveChanged() { surface.sync(); }
            }

            MediaPlayer {
                id: player
                source: "file://" + surface.path
                loops: MediaPlayer.Infinite
                videoOutput: surface
                audioOutput: AudioOutput { muted: true }
                onErrorOccurred: (error, errorString) => console.warn("WallpaperVideoPool:", errorString)
            }
        }
    }
}
