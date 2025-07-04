import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Wayland
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland 

ShellRoot {
    id: main

    Process {
        id: obsidian
        running: false
        command: [ "obsidian-cli", "open", "Tareas/" + main.selected_file ]
        stdout: SplitParser {
            onRead: data => window.month = data
        }
    }
    property string accent_color: "red"
    property string second_accent_color: "#BFBFFF"
    property string path: "/home/plof/.config/quickshell/"
    property string calendar: "/home/plof/Documents/Actual/actual/Tareas/"
    property string file: ""
    property string today: ""
    property string selected_file: "2025-02-06 Compiladores"
    function addText(fecha, titulo, path) {
        var checkBox = eventComponent.createObject(
            column,  // Parent the new object to the Column
            {
                "fecha": fecha,
                "titulo": titulo,
                "full_path": path,
            }
        );
    }
    Component {
        id: selected
        Rectangle {
            anchors.fill: parent  // Fill the clipRegion area
            color: "lightgray"
            radius: 16   // (antes 20)
            opacity: 0.8
        }
    }

    Component {
        id: eventComponent
        Column {
            property string fecha: ""
            property string titulo: ""
            property string full_path: ""

            Rectangle {
                MouseArea {
                id: mouseArea
                    anchors.fill: parent
                    onClicked: {
                        main.selected_file = full_path
                        console.log(full_path)
                        obsidian.running = true
                    }
                }
                color: mouseArea.pressed ? second_accent_color : "transparent"
                height: 40    // (antes 50)
                width: 320    // (antes 400)
                ColumnLayout {
                    Text {
                        text: fecha
                        font.family: window.font
                        font.pointSize: 13   // (antes 16)
                        color: main.accent_color
                    }
                    Text {
                        text: titulo + ""
                        font.family: window.font
                    }
                }
            }
        }
    }

    Component {
        id: eventDay
        Rectangle {
            anchors.fill: parent  // Fill the clipRegion area
            color: main.accent_color
            radius: 16   // (antes 20)
            opacity: 0.5
        }
    }

    Component {
        id: currentDay
        Rectangle {
            anchors.fill: parent  // Fill the clipRegion area
            color: main.accent_color
            radius: 16   // (antes 20)
            opacity: 1
        }
    }

    PanelWindow {
        id: window
        width: 500    // (antes 620)
        height: 250   // (antes 310)
        color: "transparent" // Make the panel transparent
        WlrLayershell.layer: WlrLayer.Bottom

        anchors {
            left: true
            top: true
        }
        function hasEvent(day) {
            for (var i = 0; i < eventosModel.count; i++) {
                if (eventosModel.get(i).fecha == day) {
                    return true;
                }
            }
            return false;
        }

        property var borde: 16    // (antes 20)
        property var radio: 16    // (antes 20)
        property var dayClicked: -1
        property var days: ["  S", "M", "T", "W", "T", "F", "S"]
        property var month: ""
        property var eventos: []
        property var year: 0
        property var monthDays: -1
        property var currentDay: -1
        property var monthStarts: -1
        property string font: "System Font"

        // Function to refresh events
        function refreshEvents() {
            // console.log("Refreshing events..."); // Optional: for debugging
            eventosModel.clear(); // Clear the data model

            // Clear the visual items in the column
            // Assuming 'column' is the id of the Column item holding event components
            if (typeof column !== 'undefined' && column !== null) {
                for (var i = column.children.length - 1; i >= 0; i--) {
                    if (column.children[i]) {
                        column.children[i].destroy();
                    }
                }
            }
            
            // Re-trigger the event loading process
            if (typeof eventLoaderProcess !== 'undefined' && eventLoaderProcess !== null) {
                eventLoaderProcess.running = true;
            }
        }

        Timer {
            id: eventUpdateTimer
            interval: 60000 // Update every 60 seconds (1 minute). Adjust as needed.
            running: true   // Start the timer automatically
            repeat: true    // Keep repeating
            onTriggered: {
                window.refreshEvents(); // Call the refresh function
            }
        }

        Process {
            running: true
            command: [ "date", "+%d" ]
            stdout: SplitParser {
                onRead: data => main.today = data
            }
        }
        Process {
            running: true
            command: [ "date", "+%B" ]
            stdout: SplitParser {
                onRead: data => window.month = data
            }
        }

        Process {
            running: true
            command: [ "date", "+%d" ]
            stdout: SplitParser {
                onRead: data => {
                    var f = parseInt(data);
                    window.currentDay = f;
                }
            }
        }

        property var eventos2: ListModel {
            id: eventosModel
        }
        Process {
            id: eventLoaderProcess // Added id to be able to restart it
            running: true // Initial run on startup
            command: [ "sh", main.path + "eventos.sh", main.calendar ]
            stdout: SplitParser {
                onRead: data => {
                    var path = data
                    data = data.split(" ")
                    var fecha = data[0].split("-")[2]
                    var titulo = data.slice(1).join(" ").split(".md")[0]
                    eventosModel.append({ fecha: parseInt(fecha), titulo: titulo });
                    main.addText(fecha, titulo, path); // Call to main.addText as in original
                }
            }
        }

        Process {
            running: true
            command: [ "date", "+%Y" ]
            stdout: SplitParser {
                onRead: data => {
                    var f = parseInt(data);
                    window.year = f;
                }
            }
        }

        Process {
            running: true
            command: [ "sh", main.path + "dias.sh" ]
            stdout: SplitParser {
                onRead: data => {
                    var f = parseInt(data);
                    window.monthDays = f;
                }
            }
        }

        Process {
            running: true
            command: [ "sh", main.path + "diaMes.sh" ]
            stdout: SplitParser {
                onRead: data => {
                    var f = parseInt(data);
                    window.monthStarts = f;
                }
            }
        }

        Rectangle {
            width: parent.width - window.borde
            height: parent.height - window.borde
            x: window.borde
            y: window.borde
            color: "white"
            radius: window.radio
        }

        Rectangle {
            width: parent.width - window.borde
            height: parent.height
            x: window.borde * 2
            y: window.borde
            color: "transparent"

            Rectangle {
                id: calendario
                width: childrenRect.width
                height: childrenRect.height
                anchors.horizontalCenter: parent.horizontalLeft
                color: "transparent"

                ColumnLayout {
                    Rectangle {
                        implicitHeight: childrenRect.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        RowLayout {
                            Text {
                                text: window.month
                                font.pointSize: 10   // (antes 13)
                                font.family: window.font
                                color: main.accent_color
                            }
                            Text {
                                text: window.year
                                font.pointSize: 12   // (antes 15)
                                font.family: window.font
                                color: main.accent_color
                                anchors.left: parent.rigth
                            }
                        }
                    }
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalLeft
                        Repeater {
                            model: 7
                            Rectangle {
                                x: index * 32   // (antes index * 42)
                                Text {
                                    text: window.days[index]
                                    font.pointSize: 11   // (antes 14)
                                    font.family: window.font
                                    color: "gray"
                                }
                            }
                        }
                    }
                }

                Repeater {
                    model: 37
                    Rectangle {
                        width: 32   // (antes 40)
                        height: 32   // (antes 40)
                        x: 32 * (index % 7)   // (antes 40 * (index % 7))
                        y: (32 * Math.floor(index / 7)) + 48   // (antes (40 * Math.floor(index / 7)) + 60)
                        color: "transparent"
                        Loader {
                            anchors.fill: parent
                            sourceComponent: window.dayClicked === index ? selected : null
                        }
                        Loader {
                            anchors.fill: parent
                            sourceComponent: window.currentDay === index + 1 - window.monthStarts ? currentDay : null
                        }
                        Loader {
                            anchors.fill: parent
                            sourceComponent: window.hasEvent(index + 1 - window.monthStarts) ? eventDay : null
                        }
                        Text {
                            font.family: window.font
                            text: index - window.monthStarts >= 0 && window.monthDays > index - window.monthStarts ? index + 1 - window.monthStarts : ""
                            anchors.centerIn: parent
                            font.pointSize: 11   // (antes 14)
                            color: window.currentDay === index + 1 - window.monthStarts ? "white" : (Math.floor(index % 7) === 0 ? "grey" : Math.floor(index % 7) - 6 === 0 ? "grey" : "black")
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (index < 31 + window.monthDays) { // This condition might need adjustment depending on monthStarts and monthDays logic
                                    window.dayClicked = index;
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: parent.height
                    x: (32 * 7) + 10   // (antes (40*7)+10)
                    color: "transparent"
                    Flickable {
                        anchors.fill: parent
                        contentWidth: parent.width
                        contentHeight: column.height + 16   // (antes +20)
                        Column {
                            y: 16    // (antes 20)
                            id: column // This is the column to clear children from
                            width: parent.width
                            spacing: 32   // (antes 40)
                        }
                    }
                }
            }
        }
    }
}
