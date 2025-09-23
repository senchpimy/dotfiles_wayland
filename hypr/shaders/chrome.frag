#version 300 es
// vim: set ft=glsl:

precision highp float;

in highp vec2 v_texcoord;
uniform highp sampler2D tex;

out vec4 fragColor;

#define STRENGTH 0.0027

void main() {
    vec2 center = vec2(0.5, 0.5);
    vec2 offset = (v_texcoord - center) * STRENGTH;

    float rSquared = dot(offset, offset);
    float distortion = 1.0 + 1.0 * rSquared;
    vec2 distortedOffset = offset * distortion;

    vec2 redOffset = vec2(distortedOffset.x, distortedOffset.y);
    vec2 blueOffset = vec2(distortedOffset.x, distortedOffset.y);

    vec4 redColor = texture(tex, v_texcoord + redOffset);
    vec4 blueColor = texture(tex, v_texcoord + blueOffset);
    float greenColor = texture(tex, v_texcoord).g;

    fragColor = vec4(redColor.r, greenColor, blueColor.b, 1.0);
}
