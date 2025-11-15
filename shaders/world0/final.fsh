#version 120

varying vec2 texcoord;

uniform sampler2D colortex0;

// Optifine Constants
/*
const int colortex0Format = R11F_G11F_B10F;
const int colortex2Format = RGB8;
*/

vec3 AxevileTonemap(vec3 x) {
	return x / (0.9813 * x + 0.1511);
}

void main() {
	vec3 color = texture2D(colortex0, texcoord).rgb;

	// linear to srgb
	// color = pow(color, vec3(1.0 / 2.2));
	color = AxevileTonemap(color);

	gl_FragColor = vec4(color, 1.0); //gcolor
}