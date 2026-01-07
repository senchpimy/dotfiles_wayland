import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects


Rectangle {
    id: root

    property int blurRadius: 20
    property int blurSamples: 20

    color: "transparent"


    Loader {
        id: strLoad
        source: "../lockscreen/ImagePath.qml"
    }

    Image {
        id: image
        source: strLoad.item.path // Replace with your image path
        anchors.fill: parent
  	    //fillMode: Image.PreserveAspectCrop;
	      //asynchronous: false
	      //cache: false
        //visible:true
    }

    Rectangle {
      id: blurContainment
      anchors.fill: parent
    color: "transparent"

    MouseArea {
      anchors.fill: parent
        onPositionChanged: {
          console.log(mouse.y, mouse.x)
        }
      }
    }

    Area{
      //x:550
      //y:500
      x:800
      y:500
      //anchors.fill:parent
    }

    //Apps{
    //    anchors.centerIn: parent
    //}
}
