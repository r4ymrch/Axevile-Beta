/*
- Axevile v1.0.0 - composite program.
- See README.md for more details.
*/

#version 120

#include "/lib/settings.glsl"

varying vec2 texCoord;
varying vec3 sunVector, lightVector, upVector;

uniform sampler2D noisetex;
uniform sampler2D depthtex0;
uniform sampler2D colortex0;

uniform float far, near;
uniform float rainStrength;
uniform float dayTime, nightTime;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

// Common functions
#include "/lib/utils/math.glsl"
#include "/lib/utils/luma.glsl"
#include "/lib/utils/distort.glsl"
#include "/lib/utils/spaceConvert.glsl"
#include "/lib/colors/skyColor.glsl"
#include "/lib/atmospherics/lightShaft.glsl"

void main()
{
  float z = texture2D(depthtex0, texCoord).r;
  vec3 viewPos = ToViewSpace(vec3(texCoord, z));

  vec3 outColor = texture2D(colortex0, texCoord).rgb;

  // Calculate light shaft.
  #include "/src/renderLightShaft.glsl"

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(outColor, 1.0);
}