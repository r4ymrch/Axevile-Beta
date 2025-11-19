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
varying vec3 viewPos, worldPos;
varying vec3 sunVector, sunMoonVector, upVector;

#ifdef SOLID_BLOCKS
  varying float NdotL;
  varying vec2 texCoord, lmCoord;
  varying vec3 normal;
  varying vec4 tintColor;
#endif

// Uniforms
uniform float rainStrength;
uniform float dayTime, nightTime;

#ifdef SOLID_BLOCKS
  uniform sampler2D texture;
#endif

// Common functions
const float ambientOcclusionLevel = 0.5;

#include "/lib/utils/luma.glsl"
#include "/lib/utils/math.glsl"
#include "/lib/utils/encode.glsl"
#include "/lib/colors/skyColor.glsl"
#include "/lib/atmospherics/sky.glsl"

// Main program
void main()
{
  vec4 outColor = CalcSky(normalize(viewPos), true);

  #ifdef SOLID_BLOCKS
    vec4 albedo = texture2D(texture, texCoord) * tintColor;
    outColor = albedo;
  #endif

  // apply gamma correction.
  outColor.rgb = pow(outColor.rgb, vec3(2.2));

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = outColor;

  #ifdef SOLID_BLOCKS
    /* DRAWBUFFERS:012 */
    gl_FragData[1] = vec4(lmCoord, 0.0, 1.0);
    gl_FragData[2] = vec4(EncodeNormal(normal), NdotL, 1.0);
  #endif
}