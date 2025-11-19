/*
====================================================
- Axevile shaders v1.0.0 developed and maintaned by r4ymrch.
- See README.md for more details about this shaders.
- Last modified : 11/18/2025.
====================================================
*/

// Configurations
#include "/lib/settings.glsl"

// Attributes
attribute vec4 mc_Entity;
attribute vec4 at_tangent;

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
uniform float timeAngle;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

// Common functions
#include "/lib/utils/math.glsl"
#include "/lib/utils/spaceConvert.glsl"
#include "/lib/main/sunVector.glsl"

// Main program
void main()
{
  viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
  worldPos = ToWorldSpace(viewPos);

  CalcSunVector(sunVector, sunMoonVector, upVector);

  #ifdef SOLID_BLOCKS
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	  lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    tintColor = gl_Color;

    normal = normalize(gl_NormalMatrix * gl_Normal);

    NdotL = clamp01(2.2 * dot(normal, sunMoonVector));
    if (mc_Entity.x == 10100/* || mc_Entity.x == 10105*/) NdotL = 1.0;
  #endif

  gl_Position = ftransform();
}