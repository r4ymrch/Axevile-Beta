#version 120

varying vec2 texcoord;

uniform sampler2D texture;

#include "/lib/utils.glsl"

void main() {
	vec4 color = texture2D(texture, texcoord);

	// srgb to linear
	color.rgb = SRGBToLinear(color.rgb);

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}