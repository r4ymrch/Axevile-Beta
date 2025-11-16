#include "/lib/settings.glsl"

#ifdef FSH

varying vec2 texCoord;
varying vec3 sunVector, lightVector, upVector;

uniform sampler2D noisetex;
uniform sampler2D depthtex0;
uniform sampler2D colortex0; // gcolor

uniform float far, near;
uniform float rainStrength;
uniform float dayTime, nightTime;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

#include "/lib/utils.glsl"
#include "/lib/spaceConvert.glsl"
#include "/lib/colors.glsl"
#include "/lib/lightShaft.glsl"

void RenderLightShaft(inout vec3 color, in vec3 viewPos) {
	float lightDotSun = distance(normalize(viewPos), sunVector);
	float lightDotMoon = distance(normalize(viewPos), -sunVector);

	float sunVisibility = clamp(dot(sunVector, upVector) * 24.0, 0.0, 1.0);
	float sunLSVisibility = exp(-length(lightDotSun) * 2.0) * sunVisibility;
	float moonLSVisibility = exp(-length(lightDotMoon) * 1.5) * (1.0 - sunVisibility);
	
	float lsVisibility = sunLSVisibility + moonLSVisibility;
	lsVisibility = clamp(lsVisibility, 0.0, 1.0);

	float blueNoise = texture2D(noisetex, gl_FragCoord.xy * invNoiseRes).r;
	float baseLightShaft = GetLightShaft(blueNoise);
	baseLightShaft *= (1.0 - rainStrength);
	
	float intensity = mix(0.35, 0.5, dayTime);
	intensity = mix(intensity, 0.35, nightTime);

	float lightShaft = baseLightShaft * intensity * lsVisibility;

	vec3 lightShaftColor = mix(fogColor, nightColor * 1.5, nightTime);
	lightShaftColor = SRGBToLinear(lightShaftColor) * baseLightShaft;
	
	color = mix(color, lightShaftColor, lightShaft);
}

void main() {
	vec3 color = texture2D(colortex0, texCoord).rgb;

	float z = texture2D(depthtex0, texCoord).r;
	vec3 viewPos = toViewSpace(vec3(texCoord, z));

	RenderLightShaft(color, viewPos);

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