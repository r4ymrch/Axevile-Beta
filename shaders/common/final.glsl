#include "/lib/settings.glsl"

#ifdef FSH

varying vec2 texcoord;

uniform sampler2D colortex0;

// Optifine Constants
/*
const int colortex0Format = R11F_G11F_B10F;
const int colortex1Format = RG8;
const int colortex2Format = RGB8;
*/

#include "/lib/utils.glsl"

vec3 AxevileTonemap(vec3 x) {
	return x / (0.9813 * x + 0.1511);
}

void main() {
	vec3 color = texture2D(colortex0, texcoord).rgb;
	
	color = AxevileTonemap(color);

	gl_FragColor = vec4(color, 1.0); //gcolor
}

#endif

#ifdef VSH

varying vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif