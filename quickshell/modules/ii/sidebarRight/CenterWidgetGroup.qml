import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs.modules.ii.sidebarRight
import qs.modules.ii.sidebarRight.notifications
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    radius: Appearance.rounding.normal
    color: Appearance.colors.colLayer1

    property int selectedTab: 0
    property var tabButtonList: [
        {"icon": "notifications", "name": Translation.tr("Notifications")},
        {"icon": "settings_input_component", "name": Translation.tr("Hardware")}
    ]

    ColumnLayout {
        anchors.margins: 5
        anchors.fill: parent
        spacing: 0

        Toolbar {
            Layout.alignment: Qt.AlignHCenter
            enableShadow: false
            ToolbarTabBar {
                id: tabBar
                Layout.alignment: Qt.AlignHCenter
                tabButtonList: root.tabButtonList
                currentIndex: root.selectedTab
                onCurrentIndexChanged: {
                    root.selectedTab = currentIndex;
                }
            }
        }

        SwipeView {
            id: swipeView
            Layout.topMargin: 5
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.selectedTab
            onCurrentIndexChanged: {
                root.selectedTab = currentIndex
            }

            clip: true

            NotificationList {
                id: notifList
                // Ensure it takes the full space of the SwipeView page
                width: swipeView.width
                height: swipeView.height
            }

            HardwareControls {
                id: hwControls
                width: swipeView.width
                height: swipeView.height
            }
        }
    }
}
