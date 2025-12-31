#version 300 es
// vim: set ft=glsl:
// blue light filter shader
// values from https://reshade.me/forum/shader-discussion/3673-blue-light-filter-similar-to-f-lux

precision mediump float;

in vec2 v_texcoord;

uniform sampler2D tex;

out vec4 fragColor;

void main() {

    vec4 pixColor = texture(tex, v_texcoord);

    // green
    pixColor.g *= 0.3;

    // blue
    pixColor.b *= 0.3;
    
    // red
    pixColor.r *= 0.3;

    fragColor = pixColor;
}
