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

// Uniforms
uniform sampler2D colortex0;

// Optifine Constants
/*
const int colortex0Format = R11F_G11F_B10F;
const int colortex1Format = RG8;
const int colortex2Format = RGB8;
*/

// Common functions
#include "/lib/utils/luma.glsl"
#include "/lib/utils/math.glsl"

vec3 Tonemap(vec3 x) {
	return x / (0.9813 * x + 0.1511);
}

// Main program
void main()
{
  vec3 outColor = texture2D(colortex0, texCoord).rgb;

  outColor = Tonemap(outColor);

  gl_FragColor = vec4(outColor, 1.0);
}