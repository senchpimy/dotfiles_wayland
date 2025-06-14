import QtQuick

QtObject {
    property string path: "{{image}}"
    property string color7: "{{ colors.primary_container.default.hex | set_lightness: -5.0}}"
    property string color0 : "{{ colors.on_secondary_fixed_variant.default.hex }}"

    property string containerGradientStart: "#66{{ colors.source_color.default.hex_stripped }}"
    property string containerGradientEnd:   "#33{{ colors.source_color.default.hex_stripped }}"
    property string containerBorderColor:   "#99{{ colors.source_color.default.hex_stripped }}"
    property string containerShadowColor:   "#40000000"

    property string input_back: "{{ colors.source_color.default.rgb | set_lightness: -50.0 }}"


  }
