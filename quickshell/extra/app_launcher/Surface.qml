import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects


Rectangle {
    id: root
    readonly property ColorGroup colors: Window.active ? palette.active : palette.inactive


    property int blurRadius: 20
    property int blurSamples: 20

    color: colors.window


    Loader {
        id: strLoad
        source: "../lockscreen/ImagePath.qml"
    }

    Image {
        id: image
        source: strLoad.item.path // Replace with your image path
        anchors.fill: parent
  	    fillMode: Image.PreserveAspectCrop;
	      asynchronous: false
	      cache: false
        visible:false
    }

    Rectangle {
      id: blurContainment
      anchors.fill: parent
    property var startY: 0

    MouseArea {
      anchors.fill: parent
        onPressed: parent.startY = mouse.y  // Guarda la posición inicial
        onPositionChanged: {
          console.log(mouse.y)
            if (mouse.y > parent.startY + 250) {  // Detecta si el usuario ha deslizado 20px hacia abajo
                console.log("Deslizando hacia abajo");
                Qt.quit()
            }
        }
        onReleased: parent.startY = 0  // Reinicia la detección
        onClicked:{
          console.log("AA")
          //Qt.quit()
        }
      }

        ShaderEffectSource {
            id: blurSource
            sourceItem: image
            sourceRect: Qt.rect(image.x, image.y, image.width, image.height)
            live: true
            anchors.fill: parent
            visible: true
        }

        Item {
            id: blurredItem
            width: blurContainment.width
            height: blurContainment.height
            clip: true

            GaussianBlur {
                source: blurSource
                radius: root.blurRadius
                samples: root.blurSamples
                anchors.fill: parent
            }
        }
    }

    Apps{
        anchors.centerIn: parent
        //horizontalCenter: parent.horizontalCenter
    }


    ColumnLayout {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 50
        }
    }
}
