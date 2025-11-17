#version 120

varying vec2 texCoord;

uniform sampler2D colortex0;

// Optifine Constants
/*
const int colortex0Format = R11F_G11F_B10F;
const int colortex1Format = RG8;
const int colortex2Format = RGB8;
const int colortex4Format = RGB8;
*/

vec3 Tonemap(vec3 x) {
	return x / (0.9813 * x + 0.1511);
}

void main()
{
  vec3 outColor = texture2D(colortex0, texCoord).rgb;

  // Back to sRGB
  outColor.rgb = Tonemap(outColor.rgb);

  gl_FragColor = vec4(outColor, 1.0);
}