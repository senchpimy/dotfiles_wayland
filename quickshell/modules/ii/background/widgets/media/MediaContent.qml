import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
import qs.modules.common.functions
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.models

Item {
    id: root
    property bool isDesktop: false
    
    // Lista de todos los players disponibles
    property var allPlayers: Mpris.players.values
    property int currentPlayerIndex: 0
    property var currentPlayer: allPlayers.length > 0 ? allPlayers[currentPlayerIndex] : null
    
    implicitWidth: 600
    implicitHeight: 150
    visible: allPlayers.length > 0
    
    // Indicadores de página (puntos)
    Row {
        id: pageIndicators
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 5
        }
        spacing: 8
        z: 100
        visible: allPlayers.length > 1
        
        Repeater {
            model: root.allPlayers.length
            
            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: index === root.currentPlayerIndex ? Appearance.colors.colOnLayer0 : Appearance.colors.colSubtext
                opacity: index === root.currentPlayerIndex ? 1.0 : 0.5
                
                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
    }
    
    // Contenedor con clipping para el efecto de slide
    Item {
        id: slideContainer
        anchors.fill: parent
        clip: true
        
        // MouseArea para capturar la rueda del mouse
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            
            onWheel: (wheel) => {
                if (root.allPlayers.length > 1) {
                    if (wheel.angleDelta.y > 0) {
                        // Scroll arriba - reproductor anterior
                        if (root.currentPlayerIndex > 0) {
                            root.currentPlayerIndex--
                        }
                    } else if (wheel.angleDelta.y < 0) {
                        // Scroll abajo - reproductor siguiente
                        if (root.currentPlayerIndex < root.allPlayers.length - 1) {
                            root.currentPlayerIndex++
                        }
                    }
                }
            }
        }
        
        // Row que contiene todas las páginas de players
        Row {
            id: pagesRow
            spacing: 0
            
            x: -root.currentPlayerIndex * root.width
            
            Behavior on x {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }
            
            Repeater {
                model: root.allPlayers
                
                Item {
                    width: root.width
                    height: root.height
                    
                    property var player: modelData
                    property string artUrl: player ? (player.metadata["mpris:artUrl"] || "") : ""
                    
                    ColorQuantizer {
                        id: colorQuantizer
                        source: artUrl
                        depth: 0
                        rescaleSize: 1
                    }

                    property color artDominantColor: ColorUtils.mix((colorQuantizer?.colors[0] ?? Appearance.colors.colPrimary), Appearance.colors.colPrimaryContainer, 0.8)
                    
                    property QtObject blendedColors: AdaptedMaterialScheme {
                        color: artDominantColor
                    }

                    ColumnLayout {
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        // Fondo con el mismo efecto que en el escritorio
                        Rectangle {
                            id: background
                            height: 150
                            width: 600
                            radius: Appearance.rounding.large
                            color: ColorUtils.applyAlpha(blendedColors.colLayer0, 1)
                            
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: background.width
                                    height: background.height
                                    radius: background.radius
                                }
                            }

                            Image {
                                id: blurredArt
                                anchors.fill: parent
                                source: artUrl
                                sourceSize.width: background.width
                                sourceSize.height: background.height
                                fillMode: Image.PreserveAspectCrop
                                cache: true
                                antialiasing: true
                                asynchronous: true

                                layer.enabled: true
                                layer.effect: StyledBlurEffect {
                                    source: blurredArt
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: ColorUtils.transparentize(blendedColors.colLayer0, 0.3)
                                    radius: background.radius
                                }
                            }
                            
                            border.width: 1
                            border.color: Appearance.colors.colLayer0Border
                        }
                        
                        // Contenido (Imagen y controles)
                        Rectangle {
                            anchors.top: parent.top
                            color: "transparent"
                            
                            RowLayout {
                                spacing: 180
                                
                                // Imagen del álbum
                                Item {
                                    anchors {
                                        top: parent.top
                                        left: parent.left
                                        leftMargin: 10
                                        topMargin: 10
                                    }
                                    
                                    Image {
                                        id: albumArt
                                        source: artUrl
                                        width: 130
                                        height: 130
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                        
                                        layer.enabled: true
                                        layer.effect: OpacityMask {
                                            maskSource: Rectangle {
                                                width: albumArt.width
                                                height: albumArt.height
                                                radius: Appearance.rounding.large
                                            }
                                        }
                                    }
                                }
                                
                                // Información y controles
                                Rectangle {
                                    color: "transparent"
                                    anchors {
                                        top: parent.top
                                        topMargin: 90
                                    }
                                    
                                    // Nombre del player (app)
                                    Text {
                                        anchors {
                                            top: parent.top
                                            topMargin: -90
                                        }
                                        text: player ? player.identity : ""
                                        font.pointSize: 10
                                        font.family: Appearance.font.family.main
                                        color: blendedColors.colSubtext
                                        renderType: Text.NativeRendering
                                    }
                                    
                                    // Título de la canción
                                    Text {
                                        anchors {
                                            top: parent.top
                                            topMargin: -70
                                        }
                                        text: {
                                            const title = player ? (player.metadata["xesam:title"] || "") : ""
                                            return title.length < 32 ? title : title.slice(0, 32) + "..."
                                        }
                                        font.pointSize: 21
                                        font.bold: true
                                        font.family: Appearance.font.family.title
                                        color: blendedColors.colOnLayer0
                                        renderType: Text.NativeRendering
                                    }
                                    
                                    // Artista
                                    Text {
                                        anchors {
                                            top: parent.top
                                            topMargin: -30
                                        }
                                        text: {
                                            var artist = player ? (player.metadata["xesam:artist"] || "") : ""
                                            if (Array.isArray(artist)) {
                                                return artist.join(", ")
                                            }
                                            return String(artist)
                                        }
                                        font.pointSize: 15
                                        font.family: Appearance.font.family.main
                                        color: blendedColors.colSubtext
                                        renderType: Text.NativeRendering
                                    }
                                    
                                    // Controles de reproducción
                                    RowLayout {
                                        spacing: 90
                                        
                                        Button {
                                            focusPolicy: Qt.NoFocus
                                            implicitHeight: 45
                                            implicitWidth: 45
                                            enabled: player && player.canGoPrevious
                                            opacity: enabled ? 1.0 : 0.3
                                            
                                            onClicked: {
                                                if (player && player.canGoPrevious) {
                                                    player.previous()
                                                }
                                            }
                                            
                                            background: Rectangle { color: "transparent" }
                                            
                                            Image {
                                                width: parent.width
                                                height: parent.height
                                                source: "file://" + Quickshell.shellPath("assets/lockscreen/previous.svg")
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            
                                            scale: pressed ? 0.8 : 1.0
                                            Behavior on scale { NumberAnimation { duration: 100 } }
                                        }
                                        
                                        Button {
                                            focusPolicy: Qt.NoFocus
                                            implicitHeight: 45
                                            implicitWidth: 45
                                            enabled: player && player.canPause
                                            
                                            onClicked: {
                                                if (player) {
                                                    if (player.playbackState === MprisPlaybackState.Playing) {
                                                        if (player.canPause) {
                                                            player.pause()
                                                        }
                                                    } else {
                                                        if (player.canPlay) {
                                                            player.play()
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            background: Rectangle { color: "transparent" }
                                            
                                            Image {
                                                width: parent.width
                                                height: parent.height
                                                source: "file://" + Quickshell.shellPath("assets/lockscreen/play-pause.svg")
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            
                                            scale: pressed ? 0.8 : 1.0
                                            Behavior on scale { NumberAnimation { duration: 100 } }
                                        }
                                        
                                        Button {
                                            focusPolicy: Qt.NoFocus
                                            implicitHeight: 45
                                            implicitWidth: 45
                                            enabled: player && player.canGoNext
                                            opacity: enabled ? 1.0 : 0.3
                                            
                                            onClicked: {
                                                if (player && player.canGoNext) {
                                                    player.next()
                                                }
                                            }
                                            
                                            background: Rectangle { color: "transparent" }
                                            
                                            Image {
                                                width: parent.width
                                                height: parent.height
                                                source: "file://" + Quickshell.shellPath("assets/lockscreen/next.svg")
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            
                                            scale: pressed ? 0.8 : 1.0
                                            Behavior on scale { NumberAnimation { duration: 100 } }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
