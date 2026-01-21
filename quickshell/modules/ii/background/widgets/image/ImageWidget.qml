import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import qs
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.common.widgets.widgetCanvas
import qs.modules.ii.background.widgets

AbstractBackgroundWidget {
    id: root
    configEntryName: "image"
    
    implicitWidth: imageContainer.width
    implicitHeight: imageContainer.height
    
    property real imgWidth: Config.options.background.widgets.image.width
    property real imgHeight: Config.options.background.widgets.image.height
    property real imgOpacity: Config.options.background.widgets.image.opacity
    
    // Lista de imágenes
    property var imageList: [
        //"/home/plof/Documents/gettyImagesIngrid.png",
        "/home/plof/Downloads/peces.gif"
    ]
    
    property int currentIndex: 0
    property int slideDirection: 1
    property bool isAnimating: false
    
    function nextImage() { slideAction(1); }
    function prevImage() { slideAction(-1); }
    
    function slideAction(direction) {
        if (isAnimating) return;
        isAnimating = true;
        root.slideDirection = direction;
        
        // Mostrar indicadores
        indicatorTimer.restart();
        
        // Preparar imagen offscreen con la imagen actual
        offscreenImage.source = mainImage.source;
        offscreenImage.playing = true; // Asegurar que el GIF se reproduce
        offscreenImage.x = 0;
        
        // Cambiar índice
        currentIndex = (currentIndex + direction + imageList.length) % imageList.length;
        
        // Posicionar nueva imagen fuera de pantalla
        mainImage.x = direction > 0 ? root.imgWidth : -root.imgWidth;
        
        slideAnimation.start();
        Config.setNestedValue("background.widgets.image.path", imageList[currentIndex]);
    }
    
    ParallelAnimation {
        id: slideAnimation
        
        NumberAnimation { 
            target: mainImage
            property: "x"
            to: 0
            duration: 500
            easing.type: Easing.InOutCubic
        }
        
        NumberAnimation { 
            target: offscreenImage
            property: "x"
            to: root.slideDirection > 0 ? -root.imgWidth : root.imgWidth
            duration: 500
            easing.type: Easing.InOutCubic
        }
        
        onFinished: {
            isAnimating = false;
            offscreenImage.source = "";
            offscreenImage.x = 0;
        }
    }
    
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    
    onClicked: (mouse) => {
        if (mouse.button === Qt.LeftButton) root.nextImage();
        else if (mouse.button === Qt.RightButton) root.prevImage();
    }
    
    onWheel: (wheel) => {
        if (wheel.angleDelta.y > 0) root.prevImage();
        else if (wheel.angleDelta.y < 0) root.nextImage();
    }
    
    // Contenedor principal simplificado
    Item {
        id: imageContainer
        width: root.imgWidth
        height: root.imgHeight
        
        // Máscara para esquinas redondeadas
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: imageContainer.width
                height: imageContainer.height
                radius: Appearance.rounding.large
            }
        }
        
        // Contenedor para recorte durante la animación
        Item {
            anchors.fill: parent
            
            // Imagen offscreen (para transiciones)
            AnimatedImage {
                id: offscreenImage
                width: parent.width
                height: parent.height
                y: 0
                fillMode: Image.PreserveAspectCrop
                opacity: root.imgOpacity
                playing: true
                cache: false
                asynchronous: true
                smooth: true
            }
            
            // Imagen principal
            AnimatedImage {
                id: mainImage
                width: parent.width
                height: parent.height
                y: 0
                source: {
                    let path = root.imageList[root.currentIndex];
                    return path.startsWith("/") ? "file://" + path : path;
                }
                fillMode: Image.PreserveAspectCrop
                opacity: root.imgOpacity
                playing: true
                cache: false
                asynchronous: true
                smooth: true
                
                // Forzar reproducción cuando cambia la fuente
                onSourceChanged: {
                    playing = false;
                    playing = true;
                }
            }
        }
        
        // Indicadores de navegación (aparecen solo durante navegación)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            spacing: 6
            opacity: indicatorTimer.running || isAnimating ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
            }
            
            Repeater {
                model: root.imageList.length
                
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: index === root.currentIndex ? "white" : Qt.rgba(1, 1, 1, 0.3)
                    border.color: Qt.rgba(0, 0, 0, 0.2)
                    border.width: 1
                    
                    Behavior on color {
                        ColorAnimation { duration: 300; easing.type: Easing.InOutQuad }
                    }
                    
                    Behavior on scale {
                        NumberAnimation { duration: 200; easing.type: Easing.OutBack }
                    }
                    
                    scale: index === root.currentIndex ? 1.2 : 1.0
                }
            }
        }
        
        // Timer para ocultar indicadores después de 2 segundos
        Timer {
            id: indicatorTimer
            interval: 2000
            repeat: false
        }
        
        // Botones de navegación laterales (aparecen al hover)
        Rectangle {
            id: leftButton
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 8
            width: 36
            height: 36
            radius: 18
            color: Qt.rgba(0, 0, 0, 0.5)
            opacity: leftMouseArea.containsMouse ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
            
            Text {
                anchors.centerIn: parent
                text: "‹"
                font.pixelSize: 24
                font.bold: true
                color: "white"
            }
            
            MouseArea {
                id: leftMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.prevImage()
            }
        }
        
        Rectangle {
            id: rightButton
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 8
            width: 36
            height: 36
            radius: 18
            color: Qt.rgba(0, 0, 0, 0.5)
            opacity: rightMouseArea.containsMouse ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
            
            Text {
                anchors.centerIn: parent
                text: "›"
                font.pixelSize: 24
                font.bold: true
                color: "white"
            }
            
            MouseArea {
                id: rightMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.nextImage()
            }
        }
    }
    
    Component.onCompleted: {
        for (let i = 0; i < imageList.length; i++) {
            if (imageList[i] === Config.options.background.widgets.image.path) {
                currentIndex = i;
                break;
            }
        }
    }
}
