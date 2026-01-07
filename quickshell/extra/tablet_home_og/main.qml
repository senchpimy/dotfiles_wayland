import QtQuick
import Quickshell

import Quickshell.Wayland

ShellRoot {

	PanelWindow {
    width: 3000
    height: 2000
    WlrLayershell.layer: WlrLayer.Bottom
		Surface {
			anchors.fill: parent
		}
  }
    //

	// exit the example if the window closes
	Connections {
		target: Quickshell

		function onLastWindowClosed() {
			Qt.quit();
		}
	}
}
