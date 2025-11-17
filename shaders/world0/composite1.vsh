/*
- Axevile v1.0.0 - composite program.
- See README.md for more details.
*/

#version 120

#include "/lib/settings.glsl"

varying vec2 texCoord;
varying vec3 sunVector, lightVector, upVector;

uniform float timeAngle;
uniform mat4 gbufferModelView;

// Common functions
#include "/lib/utils/math.glsl"

void main()
{
  texCoord = gl_MultiTexCoord0.xy;
  
  // Calculate sun vectors.
  #include "/src/sunVector.glsl"

  gl_Position = ftransform();
}