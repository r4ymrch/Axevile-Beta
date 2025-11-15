#version 120

varying vec2 texcoord;

uniform sampler2D noisetex;
uniform sampler2D depthtex0;
uniform sampler2D colortex0; // gcolor
uniform sampler2D colortex2; // gnormal

uniform float aspectRatio;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

#include "/lib/utils.glsl"
#include "/lib/encode.glsl"
#include "/lib/ssao.glsl"

vec3 toViewSpace(vec3 screenPos) {
	vec4 position = vec4(screenPos, 1.0) * 2.0 - 1.0;
	vec4 viewSpace = gbufferProjectionInverse * position;
	return viewSpace.xyz / viewSpace.w;
}

void main() {
	float z = texture2D(depthtex0, texcoord).r;
	vec3 viewSpace = toViewSpace(vec3(texcoord, z));
	vec3 worldSpace = mat3(gbufferModelViewInverse) * viewSpace + gbufferModelViewInverse[3].xyz;

	vec3 color = texture2D(colortex0, texcoord).rgb;
	vec3 normal = DecodeNormal(texture2D(colortex2, texcoord).rg);

	// float NdotL = texture2D(colortex2, texcoord).b;
	float blueNoise = texture2D(noisetex, gl_FragCoord.xy * invNoiseRes).r;
	color *= AmbientOcclusion(blueNoise);

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}