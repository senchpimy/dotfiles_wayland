#version 300 es
// vim: set ft=glsl:
// blue light filter shader
// values from https://reshade.me/forum/shader-discussion/3673-blue-light-filter-similar-to-f-lux

precision mediump float;

// 'varying' se cambia por 'in'
in vec2 v_texcoord;

uniform sampler2D tex;

// Se declara una variable de salida para el color
out vec4 fragColor;

void main() {

    vec4 pixColor = texture(tex, v_texcoord);

    // green
    pixColor.g *= 0.5;

    // blue
    pixColor.b *= 0.5;
    
    // red
    pixColor.r *= 0.5;

    // 'gl_FragColor' se cambia por el nombre de tu variable de salida
    fragColor = pixColor;
}
