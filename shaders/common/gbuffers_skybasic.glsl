#include "/lib/settings.glsl"

#ifdef FSH

varying vec3 viewPos;
varying vec3 sunVector, lightVector, upVector;

uniform float rainStrength;
uniform float dayTime, nightTime;

uniform mat4 gbufferModelView;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

#include "/lib/utils.glsl"
#include "/lib/spaceConvert.glsl"
#include "/lib/colors.glsl"
#include "/lib/sky.glsl"

void main() {
	vec3 worldPos = toWorldSpace(viewPos);
	vec4 color = CalcSky(normalize(viewPos), true);

	// srgb to linear
	color.rgb = SRGBToLinear(color.rgb);

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; // gcolor
}

#endif

#ifdef VSH

varying vec3 viewPos;
varying vec3 sunVector, lightVector, upVector;

uniform float timeAngle;
uniform mat4 gbufferModelView;

void main() {
	viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	#include "/lib/src/sunVector.glsl"
	gl_Position = ftransform();
}

#endif