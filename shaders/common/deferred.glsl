#include "/lib/settings.glsl"

#ifdef FSH

varying vec2 texCoord;

uniform sampler2D noisetex;
uniform sampler2D depthtex0;
uniform sampler2D colortex0; // gcolor

uniform float aspectRatio;
uniform float viewWidth, viewHeight;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

#include "/lib/utils.glsl"
#include "/lib/ssao.glsl"

void main() {
	vec3 color = texture2D(colortex0, texCoord).rgb;

	float blueNoise = texture2D(noisetex, gl_FragCoord.xy * invNoiseRes).r;
	color *= AmbientOcclusion(blueNoise);

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); // gcolor
}

#endif

#ifdef VSH

varying vec2 texCoord;

void main() {
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	gl_Position = ftransform();
}

#endif