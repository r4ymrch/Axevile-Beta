#include "/lib/config.glsl"

#ifdef FSH

// Varyings
varying vec2 texCoord;
varying float dayMixer, nightMixer;
varying vec3 sunVec, lightVec;

// Uniforms
uniform sampler2D depthtex0;
uniform sampler2D colortex0;

uniform float far;
uniform float rainStrength;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

// Common functions
#include "/lib/utility.glsl"
#include "/lib/rand.glsl"
#include "/lib/sky.glsl"
#include "/lib/fog.glsl"

// Main program
void main() {
  float depth = texture2D(depthtex0, texCoord).r;
  
  bool sky = depth == 1.0;
  bool terrain = depth < 1.0;

  vec3 screenPos = vec3(texCoord, depth);
	vec3 viewPos = Mat4x4Vec3_To_Vec3(gbufferProjectionInverse, screenPos * 2.0 - 1.0);
  vec3 worldPos = Mat4x4Vec3_To_Vec3(gbufferModelViewInverse, viewPos);

  vec3 color = texture2D(colortex0, texCoord).rgb;
  color = DrawSkyAndFog(color, worldPos, sky);

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(color, 1.0);
}

#endif // FSH

#ifdef VSH

// Varyings
varying vec2 texCoord;

varying float dayMixer, nightMixer;
varying vec3 sunVec, lightVec;

// Uniforms
uniform int worldTime;
uniform mat4 gbufferModelView;

// Common functions
#include "/lib/utility.glsl"

// Main program
void main() {
  float timeAngle = float(worldTime) * 0.001;
  timeAngle *= 0.04166666666666667;
  
  #include "/src/mixer.glsl"
  #include "/src/sunVector.glsl"

  texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  
  gl_Position = ftransform();
}

#endif // VSH