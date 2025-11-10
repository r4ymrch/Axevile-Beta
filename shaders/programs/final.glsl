#include "/lib/config.glsl"

#ifdef FSH

// Varyings
varying vec2 texCoord;

// Uniforms
uniform sampler2D gcolor;

// Optifine Constants
/*
const int colortex0Format = R11F_G11F_B10F;
*/

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

#include "/lib/finalColor.glsl"

// Main program
void main() {
  vec3 color = texture2D(gcolor, texCoord).rgb;
  gl_FragColor = vec4(Final(color), 1.0);
}

#endif // FSH

#ifdef VSH

// Varyings
varying vec2 texCoord;

// Main program
void main() {
  texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  gl_Position = ftransform();
}

#endif // VSH