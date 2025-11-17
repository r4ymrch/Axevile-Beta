/*
- Axevile v1.0.0 - deferred program.
- See README.md for more details.
*/

#version 120

#include "/lib/settings.glsl"

varying vec2 texCoord;

uniform sampler2D noisetex;
uniform sampler2D depthtex0;
uniform sampler2D colortex0;

uniform float aspectRatio;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

// Common functions
#include "/lib/utils/math.glsl"
#include "/lib/lighting/ssao.glsl"

void main()
{
  vec3 outColor = texture2D(colortex0, texCoord).rgb;

  float blueNoise = texture2D(noisetex, gl_FragCoord.xy * invNoiseResolution).b;
  outColor *= CalcSSAO(blueNoise);

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(outColor, 1.0);
}