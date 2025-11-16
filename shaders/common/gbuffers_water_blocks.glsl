#include "/lib/settings.glsl"

#ifdef FSH

varying vec2 lmCoord, texCoord;
varying vec3 viewPos;
varying vec3 sunVector, lightVector, upVector;
varying vec4 tintColor;
varying vec4 normal;

uniform sampler2D texture;
uniform sampler2D depthtex1;
uniform sampler2D gaux1;

uniform float rainStrength;
uniform float dayTime, nightTime;
uniform float viewWidth, viewHeight;

uniform mat4 gbufferModelView;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

#include "/lib/utils.glsl"
#include "/lib/spaceConvert.glsl"
#include "/lib/colors.glsl"
#include "/lib/sky.glsl"

void main() {
	vec4 color = texture2D(texture, texCoord) * tintColor;

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; // gcolor
}

#endif

#ifdef VSH

attribute vec4 mc_Entity;

varying vec2 lmCoord, texCoord;
varying vec3 viewPos;
varying vec3 sunVector, lightVector, upVector;
varying vec4 tintColor;
varying vec4 normal;

uniform float timeAngle;
uniform mat4 gbufferModelView;

#include "/lib/utils.glsl"

void main() {
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	lmCoord = lmCoord  / (30.0 / 32.0) - (1.0 / 32.0);
	tintColor = gl_Color;

	viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;

	#include "/lib/src/sunVector.glsl"

	normal.rgb = normalize(gl_NormalMatrix * gl_Normal);
	// normal.a = clamp(2.2 * dot(normal.rgb, lightVector), 0.0, 1.0);
	// if (mc_Entity.x == 100 || mc_Entity.x == 105) normal.a = 1.0;

	gl_Position = ftransform();
}

#endif