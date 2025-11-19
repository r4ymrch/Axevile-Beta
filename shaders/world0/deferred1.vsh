#version 120

/*
====================================================
- Axevile shaders v1.0.0 developed and maintaned by r4ymrch.
- See README.md for more details about this shaders.
- Last modified : 11/18/2025.
====================================================
*/

// Configurations
#include "/lib/settings.glsl"

// Varyings
varying vec2 texCoord;
varying vec3 sunVector, sunMoonVector, upVector;

// Uniforms
uniform float timeAngle;
uniform mat4 gbufferModelView;

// Common functions
#include "/lib/utils/math.glsl"
#include "/lib/main/sunVector.glsl"

// Main program
void main()
{
  texCoord = gl_MultiTexCoord0.xy;

  CalcSunVector(sunVector, sunMoonVector, upVector);

  gl_Position = ftransform();
}