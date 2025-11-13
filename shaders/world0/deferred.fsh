#version 120

varying vec2 texcoord;

uniform sampler2D noisetex;
uniform sampler2D gcolor;
uniform sampler2D depthtex0;

uniform float aspectRatio;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

#include "/lib/ambientOcclusion.glsl"

void main() {
	vec3 color = texture2D(gcolor, texcoord).rgb;

	float blueNoise = texture2D(noisetex, gl_FragCoord.xy / 512.0).b;
	color *= AmbientOcclusion(blueNoise);

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}