import QtQuick
import QtQuick.Layouts
import QtQuick.Controls // Using Controls 2
import Qt5Compat.GraphicalEffects
// import Quickshell.Wayland // Assuming needed for LockContext

Item {
    id: root
    required property LockContext context

    // --- Configurables ---
    property int blurRadius: 40
    property int blurSamples: 30
    property real fadeOutMul: 1 // Animation control
    property int animationDuration: 500 // Animation duration
    property color textColorPrimary: "white"
    property color textColorSecondary: "#E0E0E0"
    // Darker, subtle background for widgets as seen in the image
    property color widgetBackgroundColor: "#33000000" // Adjust alpha and color as needed
    property int widgetRadius: 16 // Slightly smaller radius maybe
    property int widgetSpacing: 10 // Spacing between widgets
    property int mainMargin: 40 // Margin from screen edges

    // --- Background ---
    Loader {
        id: strLoad
        source: "ImagePath.qml" // Provides background image path
        property string path: "default_background.jpg" // Fallback
        property color color0: root.textColorSecondary // Fallback color (unused here directly, but maybe by context)
        property color color7: root.textColorPrimary   // Fallback color (unused here directly)
        property color input_back: "#44FFFFFF"      // Fallback input background
    }

    Item {
        id: backgroundLayer
        anchors.fill: parent

        Image {
            id: backgroundImage
            source: strLoad.item ? strLoad.item.path : strLoad.path
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            visible: false // Source for blur
        }

        GaussianBlur {
            anchors.fill: backgroundImage
            source: backgroundImage
            radius: root.blurRadius
            samples: root.blurSamples
        }

        Rectangle { // Darkening overlay for fade effect
            anchors.fill: parent
            color: "#2A000000"
            opacity: root.fadeOutMul // Fades out on unlock
            visible: opacity > 0
        }
    }

    // --- Main Content Area (Widgets, Time, Unlock) ---
    Item {
        id: mainContent
        anchors.fill: parent
        opacity: 1.0 - root.fadeOutMul // Fades in on lock

        // --- Left Column: Widgets ---
        ColumnLayout {
            id: widgetsColumn
            anchors {
                left: parent.left
                leftMargin: root.mainMargin
                top: parent.top
                // Adjust top margin to clear status bar space
                topMargin: root.mainMargin + 30
            }
            spacing: root.widgetSpacing

            // 1. Weather/Search Widget
            Rectangle {
                id: weatherWidget
                implicitWidth: 200 // Adjust width as needed
                implicitHeight: 70
                color: root.widgetBackgroundColor
                radius: root.widgetRadius

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    Image {
                        // Placeholder for Google 'G' icon or weather icon
                        source: "path/to/g_icon_or_weather.png"
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        Layout.alignment: Qt.AlignTop // Align icon to top
                        fillMode: Image.PreserveAspectFit
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Label {
                            text: "19°" // Placeholder Temperature
                            font.pointSize: 15
                            font.weight: Font.Medium
                            color: root.textColorPrimary
                        }
                        Label {
                            text: "Mostly Cloudy" // Placeholder Condition
                            font.pointSize: 12
                            color: root.textColorSecondary
                        }
                        Label {
                            text: "London" // Placeholder Location
                            font.pointSize: 12
                            color: root.textColorSecondary
                        }
                    }
                }
            }

            // 2. Calendar Events Widget
            Rectangle {
                id: eventsWidget
                implicitWidth: 200 // Match width
                implicitHeight: 80
                color: root.widgetBackgroundColor
                radius: root.widgetRadius

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 5

                    Label {
                        // Placeholder Event 1
                        text: "10:00 - 16:00 Event Name"
                        font.pointSize: 12
                        color: root.textColorPrimary
                        elide: Text.ElideRight // Truncate if too long
                    }
                    Label {
                        // Placeholder Event 2
                        text: "17:00 - 18:00 Another Meeting"
                        font.pointSize: 12
                        color: root.textColorPrimary
                        elide: Text.ElideRight
                    }
                    // Add more labels or logic for dynamic events
                }
            }

            // 3. Calendar Month View Widget (Simplified Visual)
            Rectangle {
                id: monthViewWidget
                implicitWidth: 200 // Match width
                // Adjust height based on content complexity
                implicitHeight: 160
                color: root.widgetBackgroundColor
                radius: root.widgetRadius

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 5

                    // Month Header (Optional)
                    Label {
                        text: "MAY 2024" // Placeholder or dynamic month/year
                        font.pointSize: 12
                        font.weight: Font.Medium
                        color: root.textColorPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // Day letters (S M T W T F S)
                    RowLayout {
                         spacing: 5 // Adjust spacing for grid look
                         Layout.alignment: Qt.AlignHCenter
                         Repeater { // Use Repeater for day letters
                             model: ["S", "M", "T", "W", "T", "F", "S"]
                             Label {
                                 text: modelData
                                 font.pointSize: 10
                                 color: root.textColorSecondary
                                 horizontalAlignment: Text.AlignHCenter
                                 // Give fixed width for alignment
                                 Layout.preferredWidth: 18
                             }
                         }
                    }


                    // Simplified Grid for days (Static Example)
                    // A real implementation needs logic to generate days for the month
                    GridLayout {
                        columns: 7
                        rowSpacing: 4
                        columnSpacing: 4
                        Layout.alignment: Qt.AlignHCenter

                        // Example static days - replace with dynamic generation
                        Repeater {
                            model: 35 // 5 rows * 7 columns = 35 cells
                            Label {
                                // Simple example: just numbers 1-31, others empty
                                property int dayNum: index + 1 - 4 // Offset to start month roughly
                                text: (dayNum > 0 && dayNum <= 31) ? dayNum : ""
                                font.pointSize: 10
                                color: (dayNum === 10) ? "blue" : root.textColorPrimary // Highlight day 10
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                // Fixed size for grid cells
                                //implicitWidth: 18
                                //implicitHeight: 18

                                // Add background circle for highlighted day if needed
                                background: Rectangle {
                                     color: (parent.dayNum === 10) ? root.textColorPrimary : "transparent" // Example highlight background
                                     radius: width / 2
                                     visible: parent.dayNum === 10
                                     // Adjust label color when highlighted
                                     Behavior on color { ColorAnimation { duration: 100 } }
                                }
                            }
                        }
                    }
                }
            }

            // 4. Shortcuts Widget (2x2 Grid)
            Rectangle {
                id: shortcutsWidget
                implicitWidth: 200 // Match width
                implicitHeight: 100 // Adjust height for 2 rows of circles + margins
                color: root.widgetBackgroundColor
                radius: root.widgetRadius

                GridLayout {
                    anchors.centerIn: parent // Center the grid inside the rectangle
                    columns: 2
                    rows: 2
                    columnSpacing: 15
                    rowSpacing: 15

                    // Shortcut 1
                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: "#555555AA" // Circle background
                        Image { anchors.centerIn: parent; source: "path/to/shortcut1_icon.png"; width: 20; height: 20 }
                    }
                    // Shortcut 2
                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: "#555555AA"
                        Image { anchors.centerIn: parent; source: "path/to/shortcut2_icon.png"; width: 20; height: 20 }
                    }
                    // Shortcut 3
                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: "#555555AA"
                        Image { anchors.centerIn: parent; source: "path/to/shortcut3_icon.png"; width: 20; height: 20 }
                    }
                    // Shortcut 4
                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: "#555555AA"
                        Image { anchors.centerIn: parent; source: "path/to/shortcut4_icon.png"; width: 20; height: 20 }
                    }
                }
            }

        } // End Left Widgets Column

        // --- Right Column: Date and Time ---
        ColumnLayout {
            id: dateTimeColumn
            anchors {
                right: parent.right
                rightMargin: root.mainMargin
                // Align top similar to widgets, adjust if needed
                top: parent.top
                topMargin: root.mainMargin + 30
            }
            spacing: 5 // Spacing between Date and Time
            Layout.alignment: Qt.AlignRight // Align content to the right if needed

            // Date Label (iOS Style)
            Label {
                id: dateLabel
                property var currentDate: new Date()
                // Format like "Friday, 10 May"
                text: currentDate.toLocaleDateString(Qt.locale("en_US"), "dddd, d MMMM") // Use appropriate locale
                font.pointSize: 18
                font.weight: Font.Medium // Medium weight for date
                color: root.textColorPrimary // White color
                Layout.alignment: Qt.AlignRight

                Timer { interval: 60000 * 30; running: true; repeat: true; onTriggered: dateLabel.currentDate = new Date() }
            }

            // Clock Label (iOS Style)
            Label {
                id: clockLabel
                property var currentTime: new Date()
                text: Qt.formatTime(currentTime, "hh:mm") // Format "09:29"
                font.pointSize: 80
                font.weight: Font.Bold
                color: root.textColorPrimary
                renderType: Text.NativeRendering
                Layout.alignment: Qt.AlignRight

                Timer { interval: 1000; running: true; repeat: true; onTriggered: clockLabel.currentTime = new Date() }
            }
        } // End Right Date/Time Column


        // --- Bottom Section (Unlock Prompt / Input) ---
        // (Remains largely the same as previous version, adjust margins if needed)
        ColumnLayout {
            id: bottomSectionLayout
            anchors {
                bottom: parent.bottom
                bottomMargin: 50
                horizontalCenter: parent.horizontalCenter
            }
            spacing: 15

            // Fingerprint/Face ID Prompt
            Huella {
                id: fingerprintSensor
                func: root.context
                Layout.alignment: Qt.AlignHCenter
            }

            // Password Field (Styled like iOS)
            TextField {
                id: passwordBox
                implicitWidth: 250; implicitHeight: 45; padding: 10
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 17
                color: root.textColorPrimary
                placeholderText: "Enter Passcode"
                placeholderTextColor: root.textColorSecondary
                enabled: !root.context.unlockInProgress
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText

                onTextChanged: root.context.currentText = text
                onAccepted: root.context.tryUnlock()
                Connections { target: root.context; function onCurrentTextChanged() { passwordBox.text = root.context.currentText; } }

                background: Rectangle {
                    // Use input_back from Loader or fallback
                    color: strLoad.item ? strLoad.item.input_back : "#44CCCCCC"
                    radius: height / 2
                    border.color: "#88FFFFFF"; border.width: 1
                }
                Layout.alignment: Qt.AlignHCenter
            }

            // Failure Message
            Label {
                id: failureLabel
                visible: root.context.showFailure
                text: "Incorrect Passcode"
                color: "#FF6B6B"
                font.pointSize: 14
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 5
            }

             // Swipe up to unlock indicator (Optional, kept from previous)
            Label {
                text: "Swipe up to unlock" // Or just remove if not needed
                font.pointSize: 15
                color: root.textColorPrimary
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20
                opacity: 0.8
            }

        } // End Bottom Section Layout

    } // End Main Content Area

    // --- Animations & Connections --- (Kept from previous version)
    NumberAnimation {
        target: root; property: "fadeOutMul"; from: 1; to: 0
        duration: root.animationDuration; easing.type: Easing.OutCubic
        running: true // Start fade-in immediately
    }
    Connections {
        target: root.context
        function onUnlocked() { unlockFadeOutAnimation.start(); }
    }
    NumberAnimation {
        id: unlockFadeOutAnimation
        target: root; property: "fadeOutMul"; from: 0; to: 1
        duration: root.animationDuration; easing.type: Easing.InCubic
    }
}
