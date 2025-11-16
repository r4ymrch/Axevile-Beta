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
#endif

uniform float timeAngle;
uniform mat4 gbufferModelView;

void main() 
{
  viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
  
  // Calculate sun vectors.
  #include "/src/sunVector.glsl"

  #if defined(GBUFFERS_SOLID)
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	  lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    lmCoord = lmCoord  / (30.0 / 32.0) - (1.0 / 32.0);
    tintColor = gl_Color;
  #endif

  gl_Position = ftransform();
}