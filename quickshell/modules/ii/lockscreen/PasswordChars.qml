pragma ComponentBehavior: Bound
import QtQuick
import qs
import "../../../modules/common/widgets"
import "../../../modules/common/functions"
import "../../../GlobalStates.qml" as G
import Quickshell

StyledFlickable {
    id: root
    required property int length
    contentWidth: dotsRow.implicitWidth
    contentX: (Math.max(contentWidth - width, 0))
    
    // We need strLoad to get the colors, or pass them as properties.
    // In this context, it's easier to assume the same color logic.
    property color dotColor: "white" 

    Row {
        id: dotsRow
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 4
        }
        spacing: 10
        Repeater {
            model: ScriptModel {
                values: Array(root.length)
            }
            delegate: Item {
                id: charItem
                required property int index
                implicitWidth: 10
                implicitHeight: 10
                MaterialShape {
                    id: materialShape
                    anchors.centerIn: parent
                    property list<var> charShapes: [
                        MaterialShape.Shape.Clover4Leaf,
                        MaterialShape.Shape.Arrow,
                        MaterialShape.Shape.Pill,
                        MaterialShape.Shape.SoftBurst,
                        MaterialShape.Shape.Diamond,
                        MaterialShape.Shape.ClamShell,
                        MaterialShape.Shape.Pentagon
                    ]
                    shape: charShapes[charItem.index % charShapes.length]
                    
                    implicitSize: 0
                    opacity: 0
                    scale: 0.5
                    
                    Component.onCompleted: {
                        appearAnim.start();
                    }
                    
                    ParallelAnimation {
                        id: appearAnim
                        NumberAnimation {
                            target: materialShape
                            properties: "opacity"
                            to: 1
                            duration: 50
                        }
                        NumberAnimation {
                            target: materialShape
                            properties: "scale"
                            to: 1
                            duration: 200
                            easing.type: Easing.OutBack
                        }
                        NumberAnimation {
                            target: materialShape
                            properties: "implicitSize"
                            to: 18
                            easing.type: Easing.OutBack
                        }
                    }
                }
            }
        }
    }
}