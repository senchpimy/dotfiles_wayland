import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.common.widgets.widgetCanvas
import qs.modules.ii.background.widgets

AbstractBackgroundWidget {
    id: root
    configEntryName: "pendientes"
    
    property string serverUrl: "http://localhost:8080"
    property int pend_n: 0
    property bool alreadyLoaded: false

    implicitWidth: mainContainer.implicitWidth
    implicitHeight: mainContainer.implicitHeight

    // Estilos mapeados al sistema Appearance
    readonly property color accentColor: Appearance.colors.colOnTertiaryContainer
    readonly property color primaryTextColor: Appearance.colors.colOnTertiaryContainer
    readonly property color secondaryTextColor: ColorUtils.transparentize(Appearance.colors.colOnTertiaryContainer, 0.4)
    readonly property color dividerColor: ColorUtils.transparentize(Appearance.colors.colOnTertiaryContainer, 0.15)
    readonly property color uncheckedColor: ColorUtils.transparentize(Appearance.colors.colOnTertiaryContainer, 0.5)

    Timer {
        id: reloadTimer
        interval: root.alreadyLoaded ? 60000*60 : 5000 
        running: true
        repeat: true
        onTriggered: populateColumnFromServer()
    }

    function populateColumnFromServer() {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var pendientesData;
                    try {
                      pendientesData = JSON.parse(xhr.responseText);
                      root.alreadyLoaded = true;
                    } catch (e) {
                        console.error("PendientesWidget: Error al parsear JSON:", e);
                        pendientesData = null;
                    }
                    createCheckboxesFromServerData(pendientesData);
                } else {
                    console.error("PendientesWidget: Error del servidor:", xhr.status);
                    createCheckboxesFromServerData(null);
                }
            }
        }
        xhr.open("GET", root.serverUrl + "/pendientes", true);
        xhr.send();
    }

    function sendUpdateToServer(index, isChecked) {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", root.serverUrl + "/update", true);
        xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        var data = JSON.stringify({ "index": index, "checked": isChecked });
        xhr.send(data);
    }

    function createCheckboxesFromServerData(pendientes) {
        // Limpiar columna
        for (var i = column.children.length - 1; i >= 0; i--) {
            if (column.children[i]) {
                column.children[i].destroy();
            }
        }
        root.pend_n = 0;

        if (!pendientes || !Array.isArray(pendientes) || pendientes.length === 0) {
            return;
        }

        pendientes.forEach(function(item, index) {
            if (!item) return;
            if (item.hasOwnProperty('checked') && !item.checked) {
                root.pend_n += 1;
            }
            checkBoxComponent.createObject(column, {
                "dynamicText": item.text || "Texto por defecto",
                "dynamicIndex": index,
                "dynamicCheck": !!item.checked
            });
        });
    }

    Component {
        id: checkBoxComponent
        Item {
            id: itemRoot
            width: column.width
            height: content.height + 12

            property bool checked: dynamicCheck
            property string dynamicText: "Texto no definido"
            property int dynamicIndex: -1
            property bool dynamicCheck: false

            property var _parsedData: {
                if (typeof dynamicText !== 'string' || !dynamicText) {
                    return { date: "", subject: "", description: "Texto inválido" };
                }
                
                const parts = dynamicText.split(/\s*\/\s*/);
                if (parts.length < 3) {
                    return { date: "", subject: "", description: dynamicText };
                }

                const dateMatch = parts[0].match(/(\d{4}-\d{2}-\d{2})/);
                
                return {
                    date: dateMatch ? dateMatch[1] : "",
                    subject: parts[1],
                    description: parts.slice(2).join(' / ') 
                };
            }

            property string dueDate: _parsedData.date
            property string subject: _parsedData.subject
            property string description: _parsedData.description

            readonly property string daysRemainingText: {
                if (!dueDate) return "";
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                const dateParts = dueDate.split('-');
                const dueDateObj = new Date(dateParts[0], dateParts[1] - 1, dateParts[2]);
                dueDateObj.setHours(0, 0, 0, 0);
                const diffTime = dueDateObj.getTime() - today.getTime();
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

                if (diffDays < 0) return "Venció hace " + Math.abs(diffDays) + (Math.abs(diffDays) === 1 ? " día" : " días");
                if (diffDays === 0) return "Vence hoy";
                if (diffDays === 1) return "Vence mañana";
                return "Vence en " + diffDays + " días";
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    itemRoot.checked = !itemRoot.checked;
                    sendUpdateToServer(dynamicIndex, itemRoot.checked);
                }
            }

            // Indicador (Checkbox circular)
            Rectangle {
                id: indicator
                width: 20
                height: 20
                x: 0
                y: 4
                radius: 10
                border.color: itemRoot.checked ? root.accentColor : root.uncheckedColor
                border.width: 2
                color: "transparent"

                Rectangle {
                    width: 12
                    height: 12
                    anchors.centerIn: parent
                    radius: 6
                    color: root.accentColor
                    visible: itemRoot.checked
                }
            }

            // Contenido de texto
            Column {
                id: content
                anchors.left: indicator.right
                anchors.leftMargin: 10
                anchors.right: parent.right
                
                spacing: 2

                Row {
                    width: parent.width
                    spacing: 8
                    visible: daysRemainingText !== "" || subject !== ""

                    StyledText {
                        text: daysRemainingText
                        font.pixelSize: 10
                        color: root.secondaryTextColor
                        opacity: itemRoot.checked ? 0.6 : 1.0
                        visible: daysRemainingText !== ""
                    }
                    StyledText {
                        text: subject
                        font.pixelSize: 10
                        font.bold: true
                        color: root.accentColor
                        opacity: itemRoot.checked ? 0.6 : 1.0
                        visible: subject !== ""
                    }
                }

                StyledText {
                    text: description
                    color: itemRoot.checked ? root.uncheckedColor : root.primaryTextColor
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    width: parent.width
                    elide: Text.ElideRight
                    font.strikeout: itemRoot.checked
                }
            }
        }
    }

    Rectangle {
        id: mainContainer
        implicitWidth: 320
        implicitHeight: 450
        radius: Appearance.rounding.large
        color: Appearance.colors.colTertiaryContainer

        StyledRectangularShadow {
            target: mainContainer
            visible: true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            // Header
            RowLayout {
                Layout.fillWidth: true
                StyledText {
                    text: "Pendientes"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: root.accentColor
                    Layout.fillWidth: true
                }

                StyledText {
                    text: root.pend_n
                    font.family: Appearance.font.family.numbers
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: root.primaryTextColor
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.dividerColor
                opacity: 0.3
            }

            // Lista
            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: column.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: column
                    width: parent.width
                    spacing: 5
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    active: parent.moving || parent.flicking
                }
            }
        }
    }

    Component.onCompleted: populateColumnFromServer()
}
