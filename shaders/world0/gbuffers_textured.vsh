#version 120

attribute vec4 mc_Entity;

varying vec2 lmcoord, texcoord;
varying vec3 viewSpace, worldSpace;
varying vec3 sunVector, lightVector, upVector;
varying vec4 normal;
varying vec4 glcolor;

uniform float timeAngle;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	viewSpace = (gl_ModelViewMatrix * gl_Vertex).xyz;
	worldSpace = mat3(gbufferModelViewInverse) * viewSpace + gbufferModelViewInverse[3].xyz;

	#include "/lib/src/sunVector.glsl"

	normal.rgb = normalize(gl_NormalMatrix * gl_Normal);
	normal.a = clamp(2.2 * dot(normal.rgb, lightVector), 0.0, 1.0);

	if (mc_Entity.x == 100) normal.a = 1.0;

	gl_Position = ftransform();
}