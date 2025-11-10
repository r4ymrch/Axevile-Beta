#include "/lib/config.glsl"

#ifdef FSH

// Varyings
varying vec2 texCoord, lmCoord;
varying vec3 normal;
varying vec4 glColor;

// Uniforms
uniform sampler2D texture;

// Common functions
vec3 SRGBToLinear(vec3 srgb) {
  return pow(srgb, vec3(2.2));
}

vec3 LinearToSRGB(vec3 linear) {
  return pow(linear, vec3(1.0 / 2.2));
}

float GetLuminance(vec3 x) {
  return dot(x, vec3(0.2125, 0.7154, 0.0721));
}

// Main program
void main() {
  vec4 albedo = texture2D(texture, texCoord) * glColor;

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(SRGBToLinear(albedo.rgb), albedo.a);
}

#endif // FSH

#ifdef VSH

// Varyings
varying vec2 texCoord, lmCoord;
varying vec3 normal;
varying vec4 glColor;

// Main program
void main() {
  texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  glColor = gl_Color;

  normal = normalize(gl_NormalMatrix * gl_Normal);

  gl_Position = ftransform();
}

#endif // VSH