/*
- Axevile v1.0.0 - deferred program.
- See README.md for more details.
*/

#version 120

#include "/lib/settings.glsl"

varying vec2 texCoord;

// Common functions
#include "/lib/utils/distort.glsl"

void main() {
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
  gl_Position = ftransform();
  gl_Position.xyz = DistortShadow(gl_Position.xyz);
}