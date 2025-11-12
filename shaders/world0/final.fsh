#version 120

varying vec2 uv;

uniform sampler2D gcolor;

// Optifine Constants
/*
const int colortex0Format = R11F_G11F_B10F;
*/

// Narkowicz 2015, "ACES Filmic Tone Mapping Curve"
vec3 ACESFilmic(vec3 x) {
  const float a = 2.51;
  const float b = 0.03;
  const float c = 2.43;
  const float d = 0.59;
  const float e = 0.14;
  return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

void main()
{
  vec3 color = texture2D(gcolor, uv).rgb;

  color = ACESFilmic(color);

  gl_FragColor = vec4(color, 1.0);
}