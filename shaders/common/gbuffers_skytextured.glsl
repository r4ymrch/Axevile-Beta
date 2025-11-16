#include "/lib/settings.glsl"

#ifdef FSH

varying vec2 texcoord;

uniform sampler2D texture;
uniform float rainStrength;

#include "/lib/utils.glsl"

void main() {
	vec4 color = texture2D(texture, texcoord);
	color.a *= (1.0 - rainStrength);

	// srgb to linear
	color.rgb = SRGBToLinear(color.rgb);

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; // gcolor
}

#endif

#ifdef VSH

varying vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif