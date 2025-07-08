import QtQuick

QtObject {
    property color panelBackgroundColor: "{{ colors.source_color.default.hex | set_lightness: 40.0 }}"
    property color primaryTextColor: "{{ colors.inverse_on_surface.default.hex }}" // Este no usaba set_lightness en tu ejemplo, se tomaba directo
    property color secondaryTextColor: "{{ colors.outline.default.hex }}"         // Este tampoco usaba set_lightness en tu ejemplo
    property color dividerColor: "{{ colors.outline.default.hex | set_lightness: 10.0 }}"
    property color accent_color: "{{ colors.primary.default.hex | set_lightness: -5.0 }}"
    property color unchecked_color: "{{ colors.outline.default.hex | set_lightness: 5.0 }}"
}
