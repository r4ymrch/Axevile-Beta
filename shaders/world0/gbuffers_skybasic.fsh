#version 120

varying vec3 viewSpace;
varying vec3 sunVector, lightVector, upVector;

uniform float rainStrength;
uniform float dayTime, nightTime;
uniform mat4 gbufferModelView;

#include "/lib/utils.glsl"
#include "/lib/colors.glsl"
#include "/lib/sky.glsl"

void main() {
	vec4 color = CalcSky(normalize(viewSpace));

	// srgb to linear
	color.rgb = SRGBToLinear(color.rgb);

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}