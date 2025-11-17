/*
- Axevile v1.0.0 - main program.
- See README.md for more details.
*/

#include "/lib/settings.glsl"

attribute vec4 mc_Entity;
attribute vec4 at_tangent;

varying vec3 viewPos;
varying vec3 sunVector, lightVector, upVector;

#if defined(GBUFFERS_SOLID) || defined(GBUFFERS_TRANSLUCENT)
  varying vec2 texCoord, lmCoord;
  varying vec3 tangent, binormal;
  varying vec3 viewVector;
  varying vec4 normal;
  varying vec4 tintColor;
#endif

uniform float timeAngle;
uniform mat4 gbufferModelView;

// Common functions
#include "/lib/utils/math.glsl"

void main() 
{
  viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
  
  // Calculate sun vectors.
  #include "/src/sunVector.glsl"

  #if defined(GBUFFERS_SOLID) || defined(GBUFFERS_TRANSLUCENT)
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	  lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    binormal = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
	  tangent  = normalize(gl_NormalMatrix * at_tangent.xyz);
    
    normal.xyz = normalize(gl_NormalMatrix * gl_Normal);
    normal.w = saturate(2.2 * dot(normal.xyz, lightVector));
    if (mc_Entity.x == 10100/* || mc_Entity.x == 10105*/) normal.a = 1.0;

    mat3 tbnMatrix = mat3(
    tangent.x, binormal.x, normal.x, 
		tangent.y, binormal.y, normal.y, 
		tangent.z, binormal.z, normal.z
	);

	viewVector = tbnMatrix * (gl_ModelViewMatrix * gl_Vertex).xyz;
    
    tintColor = gl_Color;
  #endif

  gl_Position = ftransform();
}