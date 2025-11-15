#version 120

attribute vec4 mc_Entity;

varying vec2 lmCoord, texCoord;
varying vec4 normal;
varying vec4 glcolor;

uniform float timeAngle;
uniform mat4 gbufferModelView;

void main() {
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	vec3 sunVector, upVector, lightVector;
	#include "/lib/src/sunVector.glsl"

	normal.rgb = normalize(gl_NormalMatrix * gl_Normal);
	normal.a = clamp(2.2 * dot(normal.rgb, lightVector), 0.0, 1.0);
	if (mc_Entity.x == 100) normal.a = 1.0;

	gl_Position = ftransform();
}