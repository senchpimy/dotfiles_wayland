import qs.modules.common
import QtQuick
import Quickshell.Widgets

// Parallax carousel, ported from pibble's WallpaperCarousel: an infinite
// horizontal strip of narrow windows with the selected item always centered.
// Each window is a fixed frame onto a wider backdrop that pans opposite the
// scroll direction (the "parallax").
//
// Unlike pibble, this is a self-contained reusable component: it takes a plain
// list of items and emits `activated(payload)` for the centered one. No
// thumbnail cache - video cells play through one shared player (see the
// WallpaperVideoPool block below), exactly like pibble - and the backend action
// is left entirely to the host.
Item {
    id: root

    // Items to show: [{ name, image, thumb, payload }]. `image` is a file path;
    // `thumb` is an optional first-frame still for video items (Image can't
    // decode a video, so the scan bakes one).
    property var items: []
    // Index of the centered item (the one `activated` is emitted for).
    property int selectedIndex: 0
    // Gated so gifs only animate while the host is actually visible.
    property bool active: false
    // Knob for the video warm pass (mirrors pibble's Settings.preload, default
    // conservative): off, videos open on-demand (~600ms first-time freeze each);
    // a host may set it true to trade RAM for instant video previews.
    property bool preload: false

    signal activated(var payload)
    signal dismissed()

    // ---- geometry (pibble's values) ----
    readonly property int barWidth: 220
    readonly property int barHeight: 440
    readonly property int slotSpacing: 262
    readonly property real parallaxPx: 75
    readonly property int captionGap: 14
    readonly property real edgeFloor: 0.7
    readonly property real edgeRate: 0.07
    readonly property real edgeBreak: (1 - edgeFloor) / edgeRate
    readonly property real edgeClampedStep: slotSpacing - barWidth * (1 - edgeFloor)

    readonly property int wallsVisible: 7
    readonly property int halfVisible: Math.floor((wallsVisible - 1) / 2)
    readonly property int bufferSlots: 2
    readonly property int restSpan: halfVisible + bufferSlots
    readonly property int totalSlots: 2 * restSpan + 1

    // Magnitude of a cell's x offset from center, as a function of |rank|.
    // Solved so consecutive cell-to-cell gaps stay exactly slotSpacing -
    // barWidth (the scale=1 gap) even as each cell shrinks around its own
    // center - plain `m * slotSpacing` opens into visibly growing gaps.
    function edgeOffset(m) {
        if (m <= edgeBreak)
            return slotSpacing * m - (barWidth * edgeRate / 2) * m * m;
        const atBreak = slotSpacing * edgeBreak - (barWidth * edgeRate / 2) * edgeBreak * edgeBreak;
        return atBreak + edgeClampedStep * (m - edgeBreak);
    }

    width: 2 * edgeOffset(halfVisible) + barWidth
    height: barHeight + captionGap + 22

    // ---- motion ----
    // Unbounded step counter; `anim` eases toward it. Selected index stays the
    // authoritative bounded value.
    property int step: 0
    property real anim: step
    property bool dragging: false
    Behavior on anim {
        enabled: !root.dragging
        NumberAnimation { duration: 420; easing.type: Easing.OutCubic }
    }

    // Bumped by restartEntrance() so cells replay their entrance spring when
    // the host reopens (the list itself usually hasn't changed by then).
    property int openTick: 0

    function move(dir) {
        const count = items.length;
        if (!count)
            return;
        step += dir;
        selectedIndex = ((selectedIndex + dir) % count + count) % count;
    }

    function jumpTo(i) {
        const count = items.length;
        if (!count)
            return;
        // Snap (not slide) to the applied item: disable the Behavior, jump,
        // re-bind. `step` is written before `selectedIndex` so onCenterItemChanged
        // captures the right slot for the shared video surface (see move()).
        dragging = true;
        step = ((i % count) + count) % count;
        selectedIndex = step;
        anim = step;
        anim = Qt.binding(() => root.step);
        dragging = false;
    }

    function dragTo(dx) {
        dragging = true;
        anim = step - dx / slotSpacing;
    }

    function dragEnd(dx, vx) {
        const carried = Math.abs(dx) + Math.abs(vx) * 0.28;
        if (carried >= 24) {
            const steps = Math.max(1, Math.round(carried / slotSpacing));
            move((dx < 0 ? 1 : -1) * steps);
        }
        dragging = false;
        anim = Qt.binding(() => root.step);
    }

    function restartEntrance() {
        openTick += 1;
    }

    function activateCenter() {
        const it = items[selectedIndex];
        if (it)
            activated(it.payload);
    }

    // A cell's `image` is a file path; .mp4 is the one video type the carousel
    // supports (matching pibble's scan). Image can't decode those files, so the
    // still frame below skips them and the shared player takes over instead.
    function isVideoPath(p) {
        return typeof p === "string" && /\.mp4$/i.test(p);
    }
    // Every video the carousel could show, for the pool's warm pass.
    readonly property var videoPaths: items.filter(it => root.isVideoPath(it.image)).map(it => it.image)

    onItemsChanged: {
        dragging = true;
        step = 0;
        selectedIndex = 0;
        anim = 0;
        anim = Qt.binding(() => root.step);
        dragging = false;
    }

    // Caption tracks the live drag position, not just the last-committed
    // selection, so it updates continuously while dragging.
    readonly property string caption: {
        const count = items.length;
        if (count === 0)
            return "";
        const idx = ((Math.round(anim) % count) + count) % count;
        const it = items[idx];
        return it ? it.name : "";
    }

    focus: true
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            dismissed();
        } else if (event.key === Qt.Key_Left) {
            move(-1);
        } else if (event.key === Qt.Key_Right) {
            move(1);
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            activateCenter();
        }
    }

    Repeater {
        id: cells
        // fixed count: delegate identity (and its absStep) stays stable across
        // steps so the strip visibly slides instead of teleporting.
        model: root.totalSlots

        Item {
            id: cell
            required property int index

            property int absStep: index - root.restSpan
            readonly property real rank: absStep - root.anim
            readonly property int count: root.items.length
            readonly property int itemIndex: count > 0 ? ((absStep % count) + count) % count : -1
            readonly property var item: itemIndex >= 0 ? root.items[itemIndex] : null
            readonly property bool isCenter: itemIndex >= 0 && itemIndex === root.selectedIndex && Math.abs(rank) < 0.5
            readonly property real selFade: Math.max(0, 1 - Math.abs(rank) * 2)
            readonly property bool isGif: item !== null && /\.gif$/i.test(item.image)
            readonly property int visSlot: Math.max(0, Math.min(root.halfVisible * 2,
                Math.round(rank) + root.halfVisible))

            // once a cell has drifted a full step past the resting buffer,
            // relabel it to the opposite edge (±totalSlots keeps it congruent
            // mod the ring) - by then it's faded to 0 opacity, so invisible.
            function rebalance() {
                while (absStep - root.anim > root.restSpan + 1)
                    absStep -= root.totalSlots;
                while (absStep - root.anim < -(root.restSpan + 1))
                    absStep += root.totalSlots;
            }

            Connections {
                target: root
                function onAnimChanged() { cell.rebalance(); }
                function onItemsChanged() { cell.absStep = cell.index - root.restSpan; }
                function onOpenTickChanged() {
                    if (cell.filled)
                        springIn.restart();
                }
            }

            x: parent.width / 2 - width / 2 + Math.sign(rank) * root.edgeOffset(Math.abs(rank))
            y: 0
            width: root.barWidth
            height: root.barHeight
            z: -Math.abs(rank)
            scale: Math.max(root.edgeFloor, 1 - Math.abs(rank) * root.edgeRate)
            opacity: Math.max(0, Math.min(1, root.halfVisible + 1 - Math.abs(rank)))

            property var shownItem: null
            property bool filled: false
            onItemChanged: {
                if (item) {
                    const wasFilled = filled;
                    const isNew = !wasFilled || !shownItem || shownItem.image !== item.image;
                    shownItem = item;
                    filled = true;
                    if (isNew) {
                        springIn.stop();
                        springOut.stop();
                        if (wasFilled) {
                            // direct replacement: snap straight to the resting
                            // state, no animation
                            wrap.opacity = 1;
                            wrap.scale = 1;
                            wrap.x = 0;
                            wrap.y = 0;
                        } else {
                            springIn.restart();
                        }
                    }
                } else if (filled) {
                    filled = false;
                    springIn.stop();
                    springOut.stop();
                    wrap.opacity = 0;
                }
            }

            Item {
                id: wrap
                // fixed size, not anchors.fill: an anchor continuously
                // re-asserts x/y against the parent, overriding the spring.
                width: parent.width
                height: parent.height
                opacity: 0

                // selected-tile ring, behind thumb and larger by the same
                // margin so it frames instead of overlapping. Opacity tracks
                // |rank| continuously (not isCenter's hard cutoff) so it
                // cross-fades between the outgoing and incoming centered card.
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -5
                    radius: Appearance.rounding.normal
                    color: "transparent"
                    border.width: 3
                    border.color: Qt.alpha(Appearance.colors.colPrimary, 0.33)
                    opacity: cell.selFade
                }

                ClippingRectangle {
                    id: thumb
                    anchors.fill: parent
                    radius: Appearance.rounding.small
                    color: Qt.alpha(Appearance.colors.colPrimary, 0.08 + 0.08 * cell.selFade)

                    // Only the centered window plays its .gif from the source
                    // file; side windows keep the still frame (frame 0).
                    readonly property bool gifAnimating: root.active && cell.isGif
                        && cell.itemIndex >= 0 && cell.itemIndex === root.selectedIndex
                        && Math.abs(cell.rank) < 1

                    // Wider than the bar and panned opposite the scroll
                    // direction, so each window reads as a fixed frame onto a
                    // slowly-drifting backdrop. Raw source (no thumbnail cache),
                    // decoded at bar height, keeps the pan free of seams.
                    Image {
                        width: root.barWidth + ((root.halfVisible + 1) * root.parallaxPx + 20) * 2
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter
                        x: (parent.width - width) / 2 - cell.rank * root.parallaxPx
                        asynchronous: true
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(0, root.barHeight)
                        // Image can't decode a .mp4, so a video cell shows the
                        // first-frame still the scan baked for it (thumb), with
                        // the shared player below painting over it once the
                        // video is open. Everything else shows the raw source.
                        source: cell.shownItem
                            ? (root.isVideoPath(cell.shownItem.image)
                                ? (cell.shownItem.thumb ? "file://" + cell.shownItem.thumb : "")
                                : "file://" + cell.shownItem.image)
                            : ""
                    }
                    AnimatedImage {
                        // Same wider-than-bar box as the still above, so
                        // PreserveAspectCrop lands on the same crop and the
                        // handover doesn't jump.
                        width: root.barWidth + ((root.halfVisible + 1) * root.parallaxPx + 20) * 2
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter
                        x: (parent.width - width) / 2 - cell.rank * root.parallaxPx
                        visible: thumb.gifAnimating
                        playing: thumb.gifAnimating
                        asynchronous: true
                        fillMode: Image.PreserveAspectCrop
                        source: thumb.gifAnimating ? "file://" + cell.shownItem.image : ""
                    }
                }

                // Stroke above the image, not a border on thumb: the clip mask
                // and an underlying border rasterize a pixel apart, so the
                // image would eat the bottom/right stroke.
                Rectangle {
                    anchors.fill: parent
                    radius: Appearance.rounding.small
                    color: "transparent"
                    border.width: 1
                    border.color: Qt.alpha(Appearance.colors.colPrimary, 0.33 + 0.67 * cell.selFade)
                }

                // TapHandler (not a plain MouseArea) so a completed swipe
                // doesn't also register as a click.
                TapHandler {
                    enabled: cell.item !== null
                    onTapped: {
                        if (cell.isCenter)
                            root.activateCenter();
                        else
                            root.move(Math.round(cell.rank));
                    }
                }
                DragHandler {
                    target: null
                    yAxis.enabled: false
                    enabled: cell.item !== null
                    property real grabX: 0
                    onActiveChanged: {
                        if (active)
                            grabX = centroid.scenePosition.x;
                        else
                            root.dragEnd(centroid.scenePosition.x - grabX, centroid.velocity.x);
                    }
                    onCentroidChanged: {
                        if (active)
                            root.dragTo(centroid.scenePosition.x - grabX);
                    }
                }
            }

            SequentialAnimation {
                id: springIn
                PropertyAction { target: wrap; property: "opacity"; value: 0 }
                PropertyAction { target: wrap; property: "scale"; value: 0.4 }
                PropertyAction { target: wrap; property: "x"; value: 14 }
                PropertyAction { target: wrap; property: "y"; value: 0 }
                // cols: 1 - the carousel is a single strip, so each bar
                // staggers individually (35ms step, like pibble's bloom).
                PauseAnimation { duration: cell.visSlot * 35 }
                ParallelAnimation {
                    NumberAnimation { target: wrap; property: "opacity"; to: 1; duration: 180; easing.type: Easing.OutCubic }
                    NumberAnimation { target: wrap; property: "scale"; to: 1; duration: 400; easing.type: Easing.OutBack; easing.overshoot: 2.2 }
                    NumberAnimation { target: wrap; property: "x"; to: 0; duration: 400; easing.type: Easing.OutBack; easing.overshoot: 2.2 }
                    NumberAnimation { target: wrap; property: "y"; to: 0; duration: 400; easing.type: Easing.OutBack; easing.overshoot: 2.2 }
                }
            }
            SequentialAnimation {
                id: springOut
                ParallelAnimation {
                    NumberAnimation { target: wrap; property: "scale"; to: 1.08; duration: 80; easing.type: Easing.OutQuad }
                }
                ParallelAnimation {
                    NumberAnimation { target: wrap; property: "scale"; to: 0.4; duration: 320; easing.type: Easing.InQuad }
                    NumberAnimation { target: wrap; property: "opacity"; to: 0; duration: 320; easing.type: Easing.InQuad }
                }
            }
        }
    }

    // ---- shared video surface (ported from pibble's WallpaperCarousel) ----
    // One video surface for the whole carousel, standing in for whichever cell
    // holds the selection, rather than one living inside each cell. Every
    // video's player is already open and paused behind it (see WallpaperVideoPool),
    // so navigation only ever moves this surface and starts/stops the player it
    // points at, both of which are free.
    readonly property var centerItem: (selectedIndex >= 0 && selectedIndex < items.length) ? items[selectedIndex] : null
    // Video the surface shows. Sticky: navigating off a video leaves it showing
    // that (now paused, and therefore identical to the still frame underneath)
    // file while it fades out riding its own cell away, rather than blanking
    // mid-slide.
    property string videoSource: ""
    // absStep of the cell videoSource was last handed over from, updated in
    // lockstep with videoSource itself (see below) so centerRank always measures
    // from the slot the open file actually belongs to - without it, a video
    // fading out would ride the incoming cell's position instead of the
    // outgoing one.
    property int videoAbsStep: root.step
    onCenterItemChanged: if (centerItem && root.isVideoPath(centerItem.image)) {
        videoSource = centerItem.image;
        videoAbsStep = root.step;
    }
    // Same ± totalSlots wrap the cells' own rebalance() applies to absStep, kept
    // in sync here too: without it, videoAbsStep is the one position on this
    // whole strip that never gets recycled, and a stale player could paint the
    // old video's frame over another cell's content later.
    function rebalanceVideo() {
        while (root.videoAbsStep - root.anim > root.restSpan + 1)
            root.videoAbsStep -= root.totalSlots;
        while (root.videoAbsStep - root.anim < -(root.restSpan + 1))
            root.videoAbsStep += root.totalSlots;
    }
    Connections {
        target: root
        function onAnimChanged() { root.rebalanceVideo(); }
    }
    // videoSource === centerItem.image holds off the handover for the frame or
    // two after a switch between two videos, while the player still has the
    // previous file open. `active`, not just existing, keeps the pool from
    // decoding frames for a carousel nobody is looking at.
    readonly property bool videoShowing: root.active && root.entranceDone
        && !!centerItem && root.isVideoPath(centerItem.image) && videoSource === centerItem.image
    // Rank of the slot the player stands in for: 0 at rest, ±1 at the start of a
    // step, free-running under a drag - which is what keeps the player over its
    // own cell throughout the motion rather than over whatever happens to be in
    // the middle.
    readonly property real centerRank: videoAbsStep - root.anim
    // The shared player has no entrance spring of its own, so hold it back until
    // the cells have finished theirs - it would otherwise sit at full opacity in
    // the center slot while the cell it stands in for is still fading/sliding
    // in. Longest case: the center cell's stagger delay plus its own duration.
    property bool entranceDone: true
    Timer {
        id: entranceSettle
        interval: root.halfVisible * 35 + 400 + 40
        onTriggered: root.entranceDone = true
    }
    onOpenTickChanged: {
        root.entranceDone = false;
        entranceSettle.restart();
    }
    Item {
        id: sharedVideo
        // the same placement/scale/stacking a cell derives from its own rank
        x: parent.width / 2 - width / 2 + Math.sign(root.centerRank) * root.edgeOffset(Math.abs(root.centerRank))
        y: 0
        width: root.barWidth
        height: root.barHeight
        scale: Math.max(root.edgeFloor, 1 - Math.abs(root.centerRank) * root.edgeRate)
        // ties with the cell it stands in for; declared after the Repeater, so
        // it wins the tie and draws over that cell's still frame
        z: -Math.abs(root.centerRank)
        // fades out toward the edges exactly as its cell does, so a slide that
        // carries a video off the strip takes the playing frame with it instead
        // of leaving it at full strength over a faded cell
        opacity: root.videoShowing
            ? Math.max(0, Math.min(1, root.halfVisible + 1 - Math.abs(root.centerRank)))
            : 0
        visible: opacity > 0
        Behavior on opacity {
            NumberAnimation { duration: 90; easing.type: Easing.OutCubic }
        }
        ClippingRectangle {
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: "transparent"
            WallpaperVideoPool {
                anchors.fill: parent
                current: root.videoSource
                live: root.videoShowing
                // Only while the carousel is closed, so the file opens land with
                // nothing on screen to stutter rather than inside a navigation.
                warming: root.preload && !root.active
                paths: root.videoPaths
                // exactly the box - and therefore exactly the crop - the
                // centered cell's still Image uses at rank 0, parallax included:
                // without it the video would sit still inside its bar while
                // everything around it panned
                surfaceWidth: root.barWidth + ((root.halfVisible + 1) * root.parallaxPx + 20) * 2
                surfaceHeight: height
                surfaceX: (width - surfaceWidth) / 2 - root.centerRank * root.parallaxPx
            }
        }
        // the centered cell's own 1px stroke is underneath this overlay, so
        // redraw it on top, in the color that cell resolves to at selFade 1.
        Rectangle {
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: "transparent"
            border.width: 1
            border.color: Appearance.colors.colPrimary
        }
    }

    Text {
        anchors.top: parent.top
        anchors.topMargin: root.barHeight + root.captionGap
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(implicitWidth, root.width)
        text: root.caption
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        color: Appearance.colors.colOnSurface
        font { family: Appearance.font.family.main; pixelSize: Appearance.font.pixelSize.smallie }
    }
}
