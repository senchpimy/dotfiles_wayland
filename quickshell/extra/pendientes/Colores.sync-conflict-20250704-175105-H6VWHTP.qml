import QtQuick

QtObject {
    property color panelBackgroundColor: "#ffffff"
    property color primaryTextColor: "#392e2b" // Este no usaba set_lightness en tu ejemplo, se tomaba directo
    property color secondaryTextColor: "#a08c87"         // Este tampoco usaba set_lightness en tu ejemplo
    property color dividerColor: "#b7a7a3"
    property color accent_color: "#ffa187"
    property color unchecked_color: "#ab9a95"
}
