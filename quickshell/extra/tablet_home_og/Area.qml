import QtQuick
import Quickshell
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Controls
import QtQuick.Shapes 
Item {
    id: root

    //anchors.fill: parent
    GridLayout {
        id: gridLayout
        columns: 6  // Ajusta según el número de columnas deseado
        rows: 5  // Ajusta según el número de columnas deseado
        rowSpacing: 100
        columnSpacing: 170
        //spacing: 170
        //width:2000
        //rowSpacing:100

        // Este Repeater toma automáticamente los hijos que sean Item o sus derivados
        //property var elements: root.children
      Icono{        
        Layout.columnSpan: 2 // Ocupa dos columnas
        Layout.fillWidth: true
      }
      Icono{
        Layout.preferredWidth: 200
            //Layout.preferredHeight: 200
            Layout.leftMargin: -20 // Solo este elemento tendrá un mayor espacio a la izquierda
            Layout.rightMargin: -20 // Solo este elemento tendrá un mayor espacio a la izquierda
      }
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
      Icono{}
    }
}
