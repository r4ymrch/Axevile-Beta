#include "/lib/config.glsl"

#ifdef FSH

// Varyings
varying vec4 uv;
varying vec4 tintColor;

varying vec3 normal;
varying float NdotL;

// Uniforms
uniform sampler2D texture;

// Common functions
#include "/lib/utility.glsl"
#include "/lib/encoding.glsl"

// Main program
void main() {
  vec4 albedo = texture2D(texture, uv.xy);

  #include "/src/vanilla.glsl"

  vec3 encodedNormal = normal * 0.5 + 0.5;

  /* DRAWBUFFERS:012 */
  gl_FragData[0] = albedo;
  gl_FragData[1] = vec4(uv.zw, 0.0, 1.0);
  gl_FragData[2] = vec4(EncodeNormal(normal), NdotL, 1.0);
}

#endif // FSH

#ifdef VSH

// Varyings
varying vec4 uv;
varying vec4 tintColor;

varying vec3 normal;
varying float NdotL;

// Attributes
attribute vec4 mc_Entity;

// Uniforms
uniform int worldTime;
uniform mat4 gbufferModelView;

// Common functions
#include "/lib/utility.glsl"

// Main program
void main() {
  float timeAngle = float(worldTime) * 0.001;
  timeAngle *= 0.04166666666666667;
  
  tintColor = gl_Color;
  uv = vec4(
    (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy, 
    (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy
  );

  vec3 sunVec, lightVec;
  #include "/src/sunVector.glsl"

  normal = normalize(gl_NormalMatrix * gl_Normal);
  
  NdotL = clamp(2.2 * dot(normal, lightVec), 0.0, 1.0);
  if (mc_Entity.x == 100) NdotL = 1.0;

  gl_Position = ftransform();
}

#endif // VSH