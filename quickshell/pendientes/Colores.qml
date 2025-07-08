import QtQuick

QtObject {
    property color panelBackgroundColor: "#b785cc"
    property color primaryTextColor: "#342f34" // Este no usaba set_lightness en tu ejemplo, se tomaba directo
    property color secondaryTextColor: "#978e97"         // Este tampoco usaba set_lightness en tu ejemplo
    property color dividerColor: "#afa9af"
    property color accent_color: "#dca1ee"
    property color unchecked_color: "#a39ba3"
}
