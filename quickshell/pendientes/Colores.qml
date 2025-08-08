import QtQuick

QtObject {
    property color panelBackgroundColor: "#c0cbda"
    property color primaryTextColor: "#2e3035" // Este no usaba set_lightness en tu ejemplo, se tomaba directo
    property color secondaryTextColor: "#8d9199"         // Este tampoco usaba set_lightness en tu ejemplo
    property color dividerColor: "#a8abb1"
    property color accent_color: "#8cbafe"
    property color unchecked_color: "#9a9ea5"
}
