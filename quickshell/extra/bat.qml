import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Quickshell
import "./lockscreen/"


ShellRoot {
  PanelWindow{
    WlrLayershell.layer: WlrLayer.Bottom
    anchors {
      left:true
    }
    color:"transparent"
    implicitWidth:1000
    implicitHeight:400
    ColumnLayout{
      x:320
      Battery{
        desktop:true
      }
    }
  }
}
