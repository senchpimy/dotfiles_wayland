import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Controls
import Quickshell.Io

Rectangle {
    id: main

    property color menuBackgroundColor: "#33000000"
    property color iconColor: "white"
    property color menuTextColor: "white"
    
    property bool expanded: false
    property int iconSize: 50
    property int menuWidth: 80
    property int spacing: 10

    width: menuWidth
    height: expanded ? iconSize + spacing + menuContent.implicitHeight : iconSize
    
    radius: expanded ? 15 : height / 2
    
    color: main.menuBackgroundColor
    clip: true

    Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
    Behavior on radius { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

    property var proc: Process {
        running: false
        command: []
    }
    

    ColumnLayout {
        id: menuContent
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 5
        
        opacity: expanded ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 200}
        }
        
        component MenuItem: Rectangle {
            required property string t_text
            required property string descrip
            required property list<string> command
            Layout.fillWidth: true
            height: 40
            color: "transparent"
            radius: 10
            Label {
                anchors.centerIn: parent
                text: parent.t_text
                color: main.menuTextColor
                font {
                    family: "Material Symbols Rounded"
                    pixelSize: 24
                }
            }
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    proc.command = command;
                    proc.running = true;
                    main.expanded = false;
                }
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "#20FFFFFF"
                    visible: parent.containsMouse
                }

                ToolTip {
                    visible: mouseArea.containsMouse 
                    text: descrip
                    delay: 500 
                }
            }
        }

        MenuItem { t_text: "power_settings_new"; descrip: "Poweroff"; command: ["systemctl", "poweroff"] }
        MenuItem { t_text: "restart_alt"; descrip: "Reboot"; command: ["systemctl", "reboot"] }
        MenuItem { t_text: "mode_standby"; descrip: "Suspend"; command: ["systemctl", "suspend"] }
    }

    MouseArea {
        id: iconButtonArea
        height: main.iconSize
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        cursorShape: Qt.PointingHandCursor
        onClicked: main.expanded = !main.expanded
        
        Label {
            id: powerIcon
            text: "drag_indicator"
            color: main.iconColor
            anchors.centerIn: parent
            font {
                family: "Material Symbols Rounded"
                pixelSize: 24
            }
            rotation: main.expanded ? 90 : 0
            Behavior on rotation {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
        }
    }
}
