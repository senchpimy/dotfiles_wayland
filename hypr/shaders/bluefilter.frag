#version 300 es
// vim: set ft=glsl:
// blue light filter shader
// values from https://reshade.me/forum/shader-discussion/3673-blue-light-filter-similar-to-f-lux

precision mediump float;
in vec2 v_texcoord;
uniform sampler2D tex;


out vec4 fragColor;
void main() {

    vec4 pixColor = texture2D(tex, v_texcoord);

    // green
    pixColor[1] *= 0.855;

    // blue
    pixColor[2] *= 0.725;

    fragColor = pixColor;
}
