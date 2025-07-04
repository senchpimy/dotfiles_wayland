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
    width:1000
    height:400
    ColumnLayout{
      x:320
      Battery{
        desktop:true
      }
    }
  }
}
