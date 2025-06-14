import QtQuick

QtObject {
    property color panelBackgroundColor: "#ffffff"
    property color primaryTextColor: "#2f3036" // Este no usaba set_lightness en tu ejemplo, se tomaba directo
    property color secondaryTextColor: "#8f9099"         // Este tampoco usaba set_lightness en tu ejemplo
    property color dividerColor: "#aaaab1"
    property color accent_color: "#96b4ff"
    property color unchecked_color: "#9c9da5"
}
