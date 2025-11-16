#include "/lib/settings.glsl"

#ifdef FSH

varying vec2 texCoord;
varying vec3 sunVector, lightVector, upVector;

uniform sampler2D depthtex0;
uniform sampler2D colortex0; // gcolor

uniform float far;
uniform float rainStrength;
uniform float dayTime, nightTime;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

#include "/lib/utils.glsl"
#include "/lib/spaceConvert.glsl"
#include "/lib/colors.glsl"
#include "/lib/sky.glsl"
#include "/lib/fog.glsl"

void DrawFog(inout vec3 color) {
	float z = texture2D(depthtex0, texCoord).r;
	vec3 viewPos = toViewSpace(vec3(texCoord, z));

	float fogFactor = GetFogFactor(viewPos, z);

	vec3 skyFog = CalcSky(normalize(viewPos), z >= 1.0).rgb;
	skyFog = SRGBToLinear(skyFog);

	color = mix(color, skyFog, fogFactor);
}

void main() {
	vec3 color = texture2D(colortex0, texCoord).rgb;

	DrawFog(color);

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); // gcolor
}

#endif

#ifdef VSH

varying vec2 texCoord;
varying vec3 sunVector, lightVector, upVector;

uniform float timeAngle;
uniform mat4 gbufferModelView;

void main() {
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	#include "/lib/src/sunVector.glsl"
	gl_Position = ftransform();
}

#endif