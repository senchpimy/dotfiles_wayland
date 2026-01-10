import QtQuick
import qs.modules.ii.background.widgets

AbstractBackgroundWidget {
    id: root
    configEntryName: "media"
    
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    MediaContent {
        id: content
        isDesktop: true
        anchors.centerIn: parent
    }
}
