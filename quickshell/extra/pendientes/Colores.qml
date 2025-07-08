import QtQuick

QtObject {
    property color panelBackgroundColor: "#f4f5f9"
    property color primaryTextColor: "#2f3036" // Este no usaba set_lightness en tu ejemplo, se tomaba directo
    property color secondaryTextColor: "#8f909a"         // Este tampoco usaba set_lightness en tu ejemplo
    property color dividerColor: "#aaabb2"
    property color accent_color: "#9ab2ff"
    property color unchecked_color: "#9c9da6"
}
