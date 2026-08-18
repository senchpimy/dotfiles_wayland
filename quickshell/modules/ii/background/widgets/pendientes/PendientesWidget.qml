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
    
    property string serverUrl: "http://192.168.100.21:8080"
    property int pend_n: 0
    property bool alreadyLoaded: false
    property var cachedData: []
    property var pendingUpdates: []

    implicitWidth: mainContainer.implicitWidth
    implicitHeight: mainContainer.implicitHeight

    FileView {
        id: cacheFile
        path: "file://" + Directories.pendientesPath
        onLoaded: {
            try {
                var data = JSON.parse(cacheFile.text());
                if (Array.isArray(data)) {
                    root.cachedData = data;
                    if (!root.alreadyLoaded) {
                        createCheckboxesFromServerData(root.cachedData);
                    }
                }
            } catch (e) {
                console.error("PendientesWidget: Error loading cache:", e);
            }
        }
    }

    FileView {
        id: pendingFile
        path: "file://" + Directories.pendingUpdatesPath
        onLoaded: {
            try {
                var data = JSON.parse(pendingFile.text());
                if (Array.isArray(data)) {
                    root.pendingUpdates = data;
                }
            } catch (e) {
                console.error("PendientesWidget: Error loading pending updates:", e);
            }
        }
        onLoadFailed: (error) => {
            if(error == FileViewError.FileNotFound) {
                root.pendingUpdates = [];
                pendingFile.setText("[]");
            }
        }
    }

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
                      if (Array.isArray(pendientesData)) {
                          root.alreadyLoaded = true;
                          root.cachedData = pendientesData;
                          cacheFile.setText(xhr.responseText);
                          // Si logramos conectar, intentamos sincronizar los pendientes
                          syncPendingUpdates();
                      } else {
                          throw new Error("Data is not an array");
                      }
                    } catch (e) {
                        console.error("PendientesWidget: Error al parsear JSON:", e);
                        pendientesData = root.cachedData;
                    }
                    createCheckboxesFromServerData(pendientesData);
                } else {
                    console.error("PendientesWidget: Error del servidor:", xhr.status);
                    if (root.cachedData && root.cachedData.length > 0) {
                        createCheckboxesFromServerData(root.cachedData);
                    } else {
                        createCheckboxesFromServerData(null);
                    }
                }
            }
        }
        xhr.open("GET", root.serverUrl + "/pendientes", true);
        xhr.send();
    }

    function sendUpdateToServer(index, isChecked) {
        // Añadir a la cola de pendientes
        // Si ya existe un update para este ID, lo actualizamos en lugar de duplicar
        var found = false;
        for (var i = 0; i < root.pendingUpdates.length; i++) {
            if (root.pendingUpdates[i].id === index) {
                root.pendingUpdates[i].checked = isChecked;
                found = true;
                break;
            }
        }
        if (!found) {
            root.pendingUpdates.push({ "id": index, "checked": isChecked });
        }
        pendingFile.setText(JSON.stringify(root.pendingUpdates));

        // Intentar enviar inmediatamente
        attemptSend(index, isChecked);
    }

    function attemptSend(index, isChecked) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    // Si se envió con éxito, lo quitamos de la cola
                    removeFromPending(index, isChecked);
                }
            }
        }
        xhr.open("POST", root.serverUrl + "/update", true);
        xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        var data = JSON.stringify({ "id": index, "checked": isChecked });
        xhr.send(data);
    }

    function removeFromPending(index, isChecked) {
        for (var i = 0; i < root.pendingUpdates.length; i++) {
            if (root.pendingUpdates[i].id === index && root.pendingUpdates[i].checked === isChecked) {
                root.pendingUpdates.splice(i, 1);
                pendingFile.setText(JSON.stringify(root.pendingUpdates));
                break;
            }
        }
    }

    function syncPendingUpdates() {
        if (root.pendingUpdates.length === 0) return;
        
        console.log("PendientesWidget: Sincronizando " + root.pendingUpdates.length + " cambios pendientes...");
        // Hacemos una copia para iterar mientras modificamos el original
        var updates = JSON.parse(JSON.stringify(root.pendingUpdates));
        updates.forEach(function(update) {
            attemptSend(update.id, update.checked);
        });
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
                "dynamicId": item.id,
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
            property int dynamicId: -1
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
                    sendUpdateToServer(itemRoot.dynamicId, itemRoot.checked);
                    
                    // Update local cache
                    for (var i = 0; i < root.cachedData.length; i++) {
                        if (root.cachedData[i].id === itemRoot.dynamicId) {
                            root.cachedData[i].checked = itemRoot.checked;
                            break;
                        }
                    }
                    cacheFile.setText(JSON.stringify(root.cachedData));
                    
                    // Update pend_n
                    if (itemRoot.checked) {
                        root.pend_n--;
                    } else {
                        root.pend_n++;
                    }
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
