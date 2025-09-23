#version 300 es
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;

out vec4 fragColor;

float CRT_CURVE_AMNTx;
float CRT_CURVE_AMNTy;
#define SCAN_LINE_MULT 1250.0

void main() {
	CRT_CURVE_AMNTx=0.2;
	CRT_CURVE_AMNTy=0.2;

	vec2 tc = v_texcoord;

	float dx = abs(0.5-tc.x);
	float dy = abs(0.5-tc.y);

	dx *= dx;
	dy *= dy;

	tc.x -= 0.5;
	tc.x *= 1.0 + (dy * CRT_CURVE_AMNTx);
	tc.x += 0.5;

	tc.y -= 0.5;
	tc.y *= 1.0 + (dx * CRT_CURVE_AMNTy);
	tc.y += 0.5;

	vec4 cta = texture(tex, tc);

	cta.rgb += sin(v_texcoord.y * SCAN_LINE_MULT) * 0.02;

	if(tc.y > 1.0 || tc.x < 0.0 || tc.x > 1.0 || tc.y < 0.0) {
		cta = vec4(0.0, 0.0, 0.0, 1.0);
    }

	fragColor = cta;
}
