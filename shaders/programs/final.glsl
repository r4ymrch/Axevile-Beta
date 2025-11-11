#include "/lib/config.glsl"

#ifdef FSH

// Varyings
varying vec2 texCoord;

// Uniforms
uniform sampler2D gcolor;

// Optifine Constants
/*
const int colortex0Format = R11F_G11F_B10F;
const int colortex1Format = RG8;
const int colortex2Format = RGBA8;
*/

// Common functions
#include "/lib/utility.glsl"
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