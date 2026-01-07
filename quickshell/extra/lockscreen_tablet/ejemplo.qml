import QtQuick
import QtQuick.Controls
Page {
    IconButton {
        anchors.centerIn: parent
        width: 100
        height: width
        icon.source: "smile.svg"
        icon.color: pressed ? "red" : "blue"
        onClicked: width < 200 ? width += 20 : width = 100
    }
}

// IconButton.qml
import QtQuick
import QtQuick.Controls
Item {
    id: iconButton
    width: 32
    height: 32
    clip: true
    property alias icon: button.icon
    property alias pressed: button.pressed
    signal clicked()
    Button {
        id: button
        anchors.centerIn: parent
        background: Item { }
        icon.width: iconButton.width
        icon.height: iconButton.height
        icon.color: "black"
        onClicked: iconButton.clicked()
    }
}
