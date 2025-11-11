#include "/lib/config.glsl"

#ifdef FSH

// Varyings
varying vec2 texCoord;
varying vec4 glColor;

// Uniforms
uniform sampler2D texture;

// Common functions
#include "/lib/utility.glsl"

// Main program
void main() {
  vec4 albedo = texture2D(texture, texCoord) * glColor;

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(SRGBToLinear(albedo.rgb), albedo.a);
}

#endif // FSH

#ifdef VSH

// Varyings
varying vec2 texCoord;
varying vec4 glColor;

// Main program
void main() {
  texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  glColor = gl_Color;
  gl_Position = ftransform();
}

#endif // VSH