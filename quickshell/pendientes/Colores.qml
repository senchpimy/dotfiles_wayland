import QtQuick

QtObject {
    property color panelBackgroundColor: "#53aacb"
    property color primaryTextColor: "#2c3134" // Este no usaba set_lightness en tu ejemplo, se tomaba directo
    property color secondaryTextColor: "#8a9296"         // Este tampoco usaba set_lightness en tu ejemplo
    property color dividerColor: "#a5abae"
    property color accent_color: "#74c7eb"
    property color unchecked_color: "#979fa2"
}
