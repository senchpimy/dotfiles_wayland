import QtQuick
import Quickshell
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import QtQuick.Controls
import QtQuick.Shapes 

Item {
    width: 1000
    height: 900
    property var icon_size: 65
    property var app: ""

    readonly property var exec: Process {
        running: false
        command: [ "setsid","gtk4-launch", app]
        //manageLifetime: false
        stdout: SplitParser {
            onRead: data => {
              console.log(data)
            }
        }
    }

    ListModel {
        id: myModel
    }

    Component {
        id: test
        Rectangle {
          radius:7
          color: isClicked ? clickedColor : defaultColor
          width:icon_size+60
          height: icon_size+21
          property color defaultColor: "transparent"
          property color clickedColor: "grey"
          property bool isClicked: false

        MouseArea {
            anchors.fill: parent
            onClicked: {parent.isClicked = !parent.isClicked
            //console.log(index)
            app = myModel.get(index).path
            console.log(app)
            exec.running=true
            Qt.quit()
          }
        }

            Column{
            anchors.horizontalCenter: parent.horizontalCenter 
              Image {
                  source: model.icono // Usar el icono del modelo
                  width: icon_size
                  height: icon_size
                  fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter // Centra la imagen en la columna (opcional)
              }
              Text {
                  text: model.nombre  // Acceso al nombre desde el modelo
                  color: "white"
                  anchors.horizontalCenter: parent.horizontalCenter 
              }
            } 
        }
    }


    readonly property var tog: Process {
        running: true
        command: [ "python", "/home/plof/.config/quickshell/app_launcher/apps.py" ]
        //manageLifetime: false
        stdout: SplitParser {
            onRead: data => {
                var str = data.trim().split("@");
                if (str.length >= 2) {
                    var nombre = str[0];
                    var icono = str[1];
                    var path = str[2];

                    // Agregar elementos al modelo
                    myModel.append({ "nombre": nombre, "icono": icono,"path":path });
                }
            }
        }
    }

ScrollView {
    id: scroll
    width: 1000
    height: 900
    clip: true
    contentWidth: -1

    Grid {
        id: grid
        spacing: 150
        columns: 4
        //anchors.centerIn: parent // Centra la grilla dentro del ScrollView
        Repeater {
            model: myModel
            delegate: test
        }
    }
}
}
