import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Wayland
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

ShellRoot {
    id: main
    property string font: "System Font"
    property string unchecked_color: "#b0b0b0"
    property string accent_color: "#1db954"
    property string serverUrl: "http://localhost:8080"
    property int pend_n: 0

    Component{
        id:separator
        Rectangle {
            width: parent.width - 30
            anchors.horizontalCenter: parent.horizontalCenter
            height: 1
            color: "#e0e0e0"
        }
    }

    Timer {
        id: reloadTimer
        interval: 3000
        running: true
        repeat: true
        onTriggered: populateColumnFromServer()
    }

    Component {
        id: checkBoxComponent
        Item {
            id: itemRoot
            width: parent.width
            height: content.height + 20

            property alias checked: dynamicCheckBox.checked
            property string dynamicText: "Texto no definido"
            property int dynamicIndex: -1
            property bool dynamicCheck: false

            property var _parsedText: {
                if (typeof dynamicText !== 'string' || !dynamicText) {
                    return { time: "", tag: "", description: "Texto inválido" };
                }
                const match = dynamicText.match(/(\d{2}:\d{2}\s*-\s*\d{2}:\d{2})\s*(#\w+)\s*(.*)/);
                if (match) {
                    return { time: match[1] || "", tag: match[2] || "", description: match[3] || "Sin descripción" };
                }
                return { time: "", tag: "", description: dynamicText };
            }

            property string timeRange: _parsedText.time
            property string tag: _parsedText.tag
            property string description: _parsedText.description

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    dynamicCheckBox.checked = !dynamicCheckBox.checked;
                    sendUpdateToServer(dynamicIndex, dynamicCheckBox.checked);
                }
            }

            CheckBox {
                id: dynamicCheckBox
                visible: false
                checked: itemRoot.dynamicCheck
            }

            Rectangle {
                id: indicator
                implicitWidth: 26
                implicitHeight: 26
                x: 15
                y: parent.height / 2 - height / 2
                radius: 13
                border.color: itemRoot.checked ? main.accent_color : main.unchecked_color
                border.width: 2

                Rectangle {
                    width: 18
                    height: 18
                    anchors.centerIn: parent
                    radius: 9
                    color: main.accent_color
                    visible: itemRoot.checked
                }
            }

            Column {
                id: content
                anchors.left: indicator.right
                anchors.leftMargin: 15
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Row {
                    width: parent.width
                    spacing: 8
                    visible: timeRange !== "" || tag !== ""

                    Text {
                        text: timeRange
                        font.family: main.font
                        font.pointSize: 10
                        color: "#777"
                        opacity: itemRoot.checked ? 0.6 : 1.0
                        visible: timeRange !== ""
                    }
                    Text {
                        text: tag
                        font.family: main.font
                        font.pointSize: 10
                        font.bold: true
                        color: main.accent_color
                        opacity: itemRoot.checked ? 0.6 : 1.0
                        visible: tag !== ""
                    }
                }

                Text {
                    text: description
                    color: itemRoot.checked ? main.unchecked_color : "#333"
                    font.family: main.font
                    font.pointSize: 13
                    wrapMode: Text.WordWrap
                    width: parent.width
                    elide: Text.ElideRight
                    font.strikeout: itemRoot.checked
                }
            }
        }
    }

    function populateColumnFromServer() {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var pendientesData;
                    try {
                        pendientesData = JSON.parse(xhr.responseText);
                    } catch (e) {
                        console.error("Error al parsear JSON:", e, "Respuesta:", xhr.responseText);
                        pendientesData = null;
                    }
                    createCheckboxesFromServerData(pendientesData);
                } else {
                    console.error("Error del servidor:", xhr.status, "Respuesta:", xhr.responseText);
                    createCheckboxesFromServerData(null);
                }
            }
        }
        xhr.open("GET", main.serverUrl + "/pendientes", true);
        xhr.send();
    }

    function sendUpdateToServer(index, isChecked) {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", main.serverUrl + "/update", true);
        xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        var data = JSON.stringify({ "index": index, "checked": isChecked });
        xhr.send(data);
    }

    function createCheckboxesFromServerData(pendientes) {
        for (var i = column.children.length - 1; i >= 0; i--) {
            if (column.children[i]) {
                column.children[i].destroy();
            }
        }
        main.pend_n = 0;

        if (!pendientes || !Array.isArray(pendientes) || pendientes.length === 0) {
            return;
        }

        pendientes.forEach(function(item, index) {
            if (!item) return;
            if (item.hasOwnProperty('checked') && !item.checked) {
                main.pend_n += 1;
            }
            // if (index > 0) { separator.createObject(column, {}); } // Descomentar para separadores entre ítems
            flickable.addDynamicCheckbox(item.text || "Texto por defecto", index, !!item.checked);
        });
    }

    PanelWindow {
        id: window
        width: 300
        height: 450
        color: "transparent" 
        anchors.left: true    
        WlrLayershell.layer: WlrLayer.Bottom
        
        property var borde: 30
        property var radio: 20

        Rectangle {
            id: mainCard 
            width: parent.width - window.borde
            height: parent.height          
            x: window.borde                 
            y: 0                             
            color: "white"
            radius: window.radio              

            Rectangle {
                anchors.fill: parent
                color: "transparent" 
                radius: parent.radius 
                clip: true 

                Column {
                    id: mainLayout
                    anchors.fill: parent
                    spacing: 0

                    Column {
                        id: headerColumn
                        width: parent.width
                        z: 1

                        Rectangle { height: 15; width: parent.width; color: "transparent" }

                        Item {
                            width: parent.width
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 15
                                anchors.rightMargin: 15

                                Text {
                                    text: "Pendientes"
                                    font.family: main.font
                                    font.pointSize: 16
                                    font.bold: true
                                    color: main.accent_color
                                    Layout.alignment: Qt.AlignLeft
                                }
                                Text {
                                    text: Number(main.pend_n)
                                    font.family: main.font
                                    font.pointSize: 16
                                    font.bold: true
                                    color: "#555"
                                    Layout.alignment: Qt.AlignRight
                                }
                            }
                        }

                        Rectangle { height: 10; width: parent.width; color: "transparent" }
                        Rectangle {
                            width: parent.width - 30
                            height: 1
                            color: "#eeeeee"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    Flickable {
                        id: flickable
                        width: parent.width
                        anchors.top: headerColumn.bottom
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        contentWidth: width
                        contentHeight: column.height
                        clip: true

                        Column {
                            id: column
                            width: parent.width
                            spacing: 0
                        }

                        function addDynamicCheckbox(lineText, index, checkedState) {
                            var newCheckBox = checkBoxComponent.createObject(
                                column,
                                {
                                    "dynamicText": lineText,
                                    "dynamicIndex": index,
                                    "dynamicCheck": checkedState
                                }
                            );
                            return newCheckBox;
                        }
                    }
                }
            }
        }

        DropShadow {
            anchors.fill: mainCard 
            source: mainCard      
            radius: 12.0
            samples: 24
            color: "#40000000"
            horizontalOffset: 0 
            verticalOffset: 4  
        }

        Component.onCompleted: {
            populateColumnFromServer();
        }
    }
}
