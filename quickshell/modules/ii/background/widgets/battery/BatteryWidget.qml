import QtQuick
import qs.modules.ii.background.widgets

AbstractBackgroundWidget {
    id: root
    configEntryName: "battery"
    
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    BatteryContent {
        id: content
        anchors.centerIn: parent
    }
}