#version 120

varying vec3 viewSpace;
varying vec3 sunVector, lightVector, upVector;

uniform float timeAngle;
uniform mat4 gbufferModelView;

void main() {
	viewSpace = (gl_ModelViewMatrix * gl_Vertex).xyz;
	#include "/lib/src/sunVector.glsl"
	gl_Position = ftransform();
}