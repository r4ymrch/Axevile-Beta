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
uniform sampler2D noisetex;
uniform sampler2D depthtex0;

uniform float rainStrength;
uniform float dayTime, nightTime;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

// Common functions
const float invNoiseResolution = 0.015625;

#include "/lib/utils/math.glsl"
#include "/lib/utils/encode.glsl"
#include "/lib/utils/spaceConvert.glsl"
#include "/lib/colors/skyColor.glsl"

// Main program
void CalcLighting(inout vec3 outColor, in vec3 viewPos, in vec2 lmCoord, in float NdotL)
{
  float sunDotUp = dot(sunVector, upVector);
  float moonDotUp = dot(-sunVector, upVector);

  float transitionFactor = max(clamp01(sunDotUp * 24.0), clamp01(moonDotUp * 6.0));
  float transition = 1.0 - transitionFactor;

  float distToSun = distance(normalize(viewPos), sunVector);
  float distToMoon = distance(normalize(viewPos), -sunVector);

  // fake subsurface effect
  float subsurface = (
    (
      exp(-distToSun * 4.0) * (1.0 - nightTime) +
      exp(-distToMoon * 4.0) * nightTime
    ) * 6.0
  );

  vec3 sunColor = mix(vec3(1.0, 0.5, 0.0), fogColor, dayTime);
  vec3 sunLight = mix(sunColor, nightColor * 0.25, nightTime);

  sunLight *= 1.0 + 1.0 * subsurface;
  sunLight *= lmCoord.y * NdotL;

  sunLight *= (1.0 - rainStrength);
  sunLight *= (1.0 - transition);

  vec3 skyBase = mix(nightColor * 0.5, skyColor * 0.75, dayTime);
  skyBase = mix(skyBase, nightColor * 0.75, transition);
  skyBase *= 1.0 + 0.35 * rainStrength;

  vec3 skyLight = skyBase * pow(lmCoord.y, 3.0);

  vec3 baseBlockLightColor = vec3(1.0, 0.9, 0.8);
  float lmX = lmCoord.x;

  vec3 blockLight = baseBlockLightColor * (
    0.2 * lmX +
    0.4 * pow3(lmX) +
    0.4 * pow6(lmX) +
    0.6 * pow8(lmX)
  );

  blockLight += vec3(1.0, 0.2, 0.0) * 6.0 * pow(lmX, 24.0);

  outColor *= (sunLight + skyLight + blockLight);
}

void main()
{
  vec3 outColor = texture2D(colortex0, texCoord).rgb;
  vec2 lightMap = texture2D(colortex1, texCoord).rg;
  vec3 gNormal = texture2D(colortex2, texCoord).rgb;

  float z = texture2D(depthtex0, texCoord).r;
  if (z == 1.0) discard;

  vec3 viewPos = ToViewSpace(vec3(texCoord, z));
  vec3 normal = DecodeNormal(gNormal.rg);

  CalcLighting(outColor, viewPos, lightMap, gNormal.b);

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(outColor, 1.0);
}