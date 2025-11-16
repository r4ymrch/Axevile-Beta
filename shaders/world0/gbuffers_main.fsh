/*
- Axevile v1.0.0 - main program.
- See README.md for more details.
*/

#include "/lib/settings.glsl"

varying vec3 viewPos;
varying vec3 sunVector, lightVector, upVector;

#if defined(GBUFFERS_SOLID)
  varying vec2 texCoord, lmCoord;
  varying vec4 tintColor;

  uniform sampler2D texture;
#endif

uniform float rainStrength;
uniform float dayTime, nightTime;

// Common functions.
#include "/lib/utils/math.glsl"
#include "/lib/utils/luma.glsl"
#include "/lib/atmospherics/sky.glsl"

void main() 
{
  vec4 outColor = CalcSky(normalize(viewPos), true);

  #if defined(GBUFFERS_SOLID)
    vec4 albedo = texture2D(texture, texCoord);

    // Reduce vanilla ao
    vec4 inColor = tintColor;
    vec3 nColor = normalize(inColor.rgb);

    if (nColor.g > nColor.b && inColor.a == 1.0) {
  	  albedo.rgb *= mix(nColor, inColor.rgb, 0.5);
    } else {
  	  albedo.rgb *= (inColor.a == 0.0) ? inColor.rgb : sqrt(inColor.rgb);
    } 
    
    outColor = albedo;
  #endif

  // Apply gamma correction
  outColor.rgb = pow(outColor.rgb, vec3(2.2));

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = outColor;
}