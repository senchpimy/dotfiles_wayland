import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Wayland
import QtQuick.Controls
import QtQuick.Layouts

ShellRoot {
    id: main
    property string font: "System Font"
    //property string font: "Hurmit Nerd Font"
    property string unchecked_color: "#9A9A99"
    property string accent_color: "#21be2b"
    property string serverUrl: "http://localhost:8080"
    property int pend_n: 0

    Component{
      id:separator
      Rectangle {
          width: parent.width - 30
          anchors.horizontalCenter: parent.horizontalCenter
          height: 2
          color: "#cccccc"
          opacity:0.5
      }
    }

    Timer {
        id: reloadTimer
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            console.log("Recargando datos desde el servidor...")
            populateColumnFromServer()
        }
    }

    Component {
        id: checkBoxComponent
        CheckBox {
            id: dynamicCheckBox
            property string dynamicText: ""
            property int dynamicIndex: 0
            property bool dynamicCheck: false
            width: parent.width
            onClicked:{
              sendUpdateToServer(dynamicIndex, dynamicCheckBox.checked)
            }

            checked: dynamicCheck
            anchors.horizontalCenter: parent.horizontalLeft
            indicator: Rectangle {
                implicitWidth: 26
                implicitHeight: 26
                x: dynamicCheckBox.leftPadding
                y: parent.height / 2 - height / 2
                radius: 20
                border.color: dynamicCheckBox.checked ?  main.accent_color :main.unchecked_color
                border.width:2

                Rectangle {
                    width: 18
                    height: 18
                    x: 4
                    y: 4
                    radius: 20
                    color: dynamicCheckBox.checked ?  main.accent_color :main.unchecked_color
                    visible: dynamicCheckBox.checked
                }
            }

            contentItem: Text {
                color: dynamicCheckBox.checked ? main.unchecked_color : "black"
                verticalAlignment: Text.AlignVCenter
                leftPadding: dynamicCheckBox.indicator.width + dynamicCheckBox.spacing
                text: dynamicText
                font.family: main.font
                font.pointSize: 13
                x: 25
                wrapMode: Text.WordWrap
                elide: Text.ElideNone
            }
        }
    }

    function populateColumnFromServer() {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var pendientes = JSON.parse(xhr.responseText);
                    createCheckboxesFromServerData(pendientes);
                } else {
                    console.error("Error al obtener datos del servidor:", xhr.status, xhr.responseText);
                }
            }
        }
        xhr.open("GET", main.serverUrl + "/pendientes", true);
        xhr.send();
    }

    function sendUpdateToServer(index, isChecked) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    console.log("Actualización enviada con éxito para el índice:", index);
                } else {
                    console.error("Error al actualizar el servidor:", xhr.status, xhr.responseText);
                }
            }
        }
        xhr.open("POST", main.serverUrl + "/update", true);
        xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        var data = JSON.stringify({ "index": index, "checked": isChecked });
        xhr.send(data);
    }

    // MODIFICADO: Ahora actualiza la cuenta de items en el Flickable.
    function createCheckboxesFromServerData(pendientes) {
        for (var i = column.children.length - 1; i >= 0; i--) {
            column.children[i].destroy();
        }
        main.pend_n = 0;
        
        // Actualizamos la propiedad que controla el padding inferior
        flickable.numItems = pendientes ? pendientes.length : 0;

        if (!pendientes) return;

        pendientes.forEach(function(item, index) {
            if (!item.checked) {
                main.pend_n += 1;
            }

            if (index > 0){
                separator.createObject(column, {})
            }
            
            flickable.addDynamicCheckbox(item.text, index, item.checked);
        });
    }

    PanelWindow {
        id: window
        width: 300
        height: 400
        color: "transparent"
        anchors.left: true
        WlrLayershell.layer: WlrLayer.Bottom
        property var borde: 30
        property var radio: 20

        Rectangle {
            width: parent.width - window.borde
            height: parent.height
            x: window.borde
            color: "white"
            opacity: 1.0
            radius: window.radio

            Rectangle {
                width: parent.width
                height: 400
                color: "white"
                clip: true
                radius: window.radio

                Rectangle {
                    id: clipRegion
                    x: 0
                    y: window.borde
                    width: parent.width
                    height: parent.height
                    color: "transparent"
                    clip: true

                    Flickable {
                        id: flickable
                        property int numItems: 0
                        anchors.fill: parent
                        contentWidth: parent.width
                        // Si hay más de 9 items, se añaden 40px de espacio extra al final
                        contentHeight: column.height + (numItems > 9 ? 40 : 0)

                        Column {
                            id: column
                            width: parent.width
                            spacing: 1
                        }

                        function addDynamicCheckbox(lineText, index, checked) {
                            var checkBox = checkBoxComponent.createObject(
                                column,
                                {
                                    "dynamicText": lineText,
                                    "dynamicIndex": index,
                                    "dynamicCheck": checked
                                }
                              );
                        }
                    }
                }
            }

            Column {
                id:col
                width: parent.width
                property var space:15

                RowLayout {
                    width: parent.width
                    spacing: 0

                    Text {
                        font.family: main.font
                        font.pointSize: 16
                        text:"Pendientes"
                        color: main.accent_color
                        Layout.alignment: Qt.AlignLeft
                        anchors.left: parent.left
                        anchors.leftMargin: col.space
                    }

                    Text {
                        font.family: main.font
                        font.pointSize: 16
                        text: Number(main.pend_n)
                        Layout.alignment: Qt.AlignRight
                        anchors.right: parent.right
                        anchors.rightMargin: col.space
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 2
                    color: "#cccccc"
                }
            }
        }

        Component.onCompleted: {
          populateColumnFromServer()
        }
    }
}
