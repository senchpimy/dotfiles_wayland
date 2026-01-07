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
    configEntryName: "calendar"
    
    property string calendarPath: Config.options.background.widgets.calendar.calendarPath
    property string selectedFile: ""
    
    implicitWidth: mainContainer.implicitWidth
    implicitHeight: mainContainer.implicitHeight
    
    property var date: new Date()
    property int currentYear: date.getFullYear()
    property int currentMonth: date.getMonth()
    property int currentDay: date.getDate()
    
    property int monthDays: new Date(currentYear, currentMonth + 1, 0).getDate()
    property int monthStarts: new Date(currentYear, currentMonth, 1).getDay()
    
    Process {
        id: obsidian
        running: false
        command: [ "obsidian-cli", "open", "Tareas/" + root.selectedFile ]
    }

    Process {
        id: notifier
        running: false
        command: ["notify-send", "-a", "Quickshell Calendar", "Abriendo evento", "Abriendo " + root.selectedFile]
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            root.date = new Date()
            root.currentYear = root.date.getFullYear()
            root.currentMonth = root.date.getMonth()
            root.currentDay = root.date.getDate()
            root.monthDays = new Date(root.currentYear, root.currentMonth + 1, 0).getDate()
            root.monthStarts = new Date(root.currentYear, root.currentMonth, 1).getDay()
            eventLoader.running = true
        }
    }

    ListModel { id: eventsModel }

    Process {
        id: eventLoader
        running: true
        // Usamos ls directo para evitar problemas de shell
        command: ["ls", "-1", root.calendarPath]
        
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() === "") return;
                const fullLine = data.trim();
                
                // Filtramos archivos .md
                if (fullLine.endsWith(".md")) {
                    const parts = fullLine.split(" ");
                    if (parts.length > 0) {
                        const datePart = parts[0];
                        // Verificamos formato YYYY-MM-DD
                        if (datePart.match(/^[0-9]{4}-[0-9]{2}-[0-9]{2}$/)) {
                             // Verificamos que sea del mes actual
                             const monthStr = String(root.currentMonth + 1).padStart(2, '0');
                             const fileMonth = datePart.split("-")[1];
                             
                             if (fileMonth === monthStr) {
                                 const day = parseInt(datePart.split("-")[2]);
                                 const title = parts.slice(1).join(" ").replace(".md", "");
                                 eventsModel.append({ "day": day, "title": title, "filename": fullLine });
                             }
                        }
                    }
                }
            }
        }
        onRunningChanged: if (running) eventsModel.clear();
    }
    
    function hasEvent(day) {
        for (let i = 0; i < eventsModel.count; i++) {
            if (eventsModel.get(i).day === day) return true;
        }
        return false;
    }

    function monthNameShort(m) {
        return Qt.locale().monthName(m, Locale.ShortFormat);
    }

    Rectangle {
        id: mainContainer
        implicitWidth: mainLayout.implicitWidth + 40
        implicitHeight: Math.max(mainLayout.implicitHeight + 40, 200)
        radius: Appearance.rounding.large
        color: Appearance.colors.colLayer1
        
        StyledRectangularShadow {
            target: mainContainer
            visible: true
        }

        RowLayout {
            id: mainLayout
            anchors.centerIn: parent
            spacing: 30

            // Calendario (Izquierda)
            ColumnLayout {
                spacing: 15
                RowLayout {
                    Layout.fillWidth: true
                    StyledText {
                        text: Qt.locale().monthName(root.currentMonth) + " " + root.currentYear
                        font.family: Appearance.font.family.main
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: Appearance.colors.colPrimary
                    }
                }

                GridLayout {
                    columns: 7
                    columnSpacing: 8
                    rowSpacing: 8
                    Repeater {
                        model: ["D", "L", "M", "X", "J", "V", "S"]
                        StyledText {
                            text: modelData
                            font.family: Appearance.font.family.main
                            font.pixelSize: 12
                            color: Appearance.colors.colOutline
                            Layout.preferredWidth: 32
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    Repeater {
                        model: root.monthStarts
                        Item { Layout.preferredWidth: 32; Layout.preferredHeight: 32 }
                    }
                    Repeater {
                        model: root.monthDays
                        Rectangle {
                            readonly property int dayNum: index + 1
                            readonly property bool isToday: root.currentDay === dayNum
                            readonly property bool isEvent: root.hasEvent(dayNum)
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 10
                            color: isToday ? Appearance.colors.colPrimary : (isEvent ? Appearance.colors.colSecondaryContainer : "transparent")
                            StyledText {
                                anchors.centerIn: parent
                                text: parent.dayNum
                                font.family: Appearance.font.family.numbers
                                font.pixelSize: 14
                                color: parent.isToday ? Appearance.colors.colOnPrimary : (parent.isEvent ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnSurface)
                            }
                        }
                    }
                }
            }

            // Lista de Pendientes (Derecha)
            ColumnLayout {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 200
                spacing: 10
                
                StyledText {
                    text: Translation.tr("Pendientes")
                    font.family: Appearance.font.family.main
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    color: Appearance.colors.colPrimary
                    visible: true
                }

                StyledText {
                    visible: eventsModel.count === 0
                    text: Translation.tr("Sin tareas")
                    font.family: Appearance.font.family.main
                    font.pixelSize: 13
                    color: Appearance.colors.colOutline
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                ListView {
                    id: eventsList
                    visible: eventsModel.count > 0
                    Layout.fillHeight: true
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: contentHeight > 0 ? contentHeight : 100
                    Layout.maximumHeight: 250
                    model: eventsModel
                    spacing: 5
                    clip: true
                    
                    delegate: Item {
                        width: 200
                        height: 40
                        
                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: mouseArea.containsMouse ? Appearance.colors.colLayer2 : (day === root.currentDay ? ColorUtils.transparentize(Appearance.colors.colSecondaryContainer, 0.5) : "transparent")
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 5
                                spacing: 8
                                
                                Rectangle {
                                    width: 4
                                    Layout.fillHeight: true
                                    Layout.topMargin: 4
                                    Layout.bottomMargin: 4
                                    radius: 2
                                    color: Appearance.colors.colPrimary
                                    visible: day === root.currentDay
                                }
                                
                                Column {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    StyledText {
                                        text: day + " " + monthNameShort(root.currentMonth)
                                        font.pixelSize: 10
                                        color: Appearance.colors.colPrimary
                                    }
                                    StyledText {
                                        text: title
                                        font.pixelSize: 13
                                        elide: Text.ElideRight
                                        width: 180
                                        color: Appearance.colors.colOnSurface
                                    }
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.selectedFile = filename
                                    notifier.running = true
                                    obsidian.running = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}