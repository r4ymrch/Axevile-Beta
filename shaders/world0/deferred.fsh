/*
====================================================
- Axevile shaders v1.0.0 developed and maintaned by r4ymrch.
- See README.md for more details about this shaders.
- Last modified : 11/18/2025.
====================================================
*/

#version 120

// Configurations
#include "/lib/settings.glsl"

// Varyings
varying vec2 texCoord;

// Uniforms
uniform sampler2D noisetex;
uniform sampler2D depthtex0;
uniform sampler2D colortex0;

uniform float aspectRatio;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

// Common functions
const float invNoiseResolution = 0.015625;

#include "/lib/utils/math.glsl"
#include "/lib/lighting/ssao.glsl"

// Main program
void main()
{
  vec3 outColor = texture2D(colortex0, texCoord).rgb;

  float bNoise = texture2D(noisetex, gl_FragCoord.xy * invNoiseResolution).b;
  outColor *= CalcSSAO(bNoise);

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(outColor, 1.0);
}