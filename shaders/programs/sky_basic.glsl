#include "/lib/config.glsl"

#ifdef FSH

// Varyings
varying float dayMixer, nightMixer;
varying vec3 sunVec, lightVec;
varying vec3 viewPos, worldPos;

// Uniforms
uniform float rainStrength;
uniform mat4 gbufferModelViewInverse;

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

#include "/lib/sky.glsl"

// Main program
void main() {
  vec3 color = CalcSky(normalize(worldPos), true);

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(SRGBToLinear(color), 0.0);
}

#endif // FSH

#ifdef VSH

// Varyings
varying float dayMixer, nightMixer;
varying vec3 sunVec, lightVec;
varying vec3 viewPos, worldPos;

// Uniforms
uniform int worldTime;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

// Common functions
#define Rotate2D(x) mat2(cos(x), sin(x), -sin(x), cos(x))

float timeAngle = float(worldTime) * 0.001 * 0.04166666666666667;

#include "/lib/spaceConvert.glsl"
#include "/lib/sunVector.glsl"

// Main program
void main() {
  dayMixer = clamp(-pow(timeAngle - 0.25, 2.0) * 20.0 + 1.25, 0.0, 1.0);
  nightMixer = clamp(-pow(timeAngle - 0.75, 2.0) * 50.0 + 3.125, 0.0, 1.0);

  SunVector(sunVec, lightVec);
  
  viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	worldPos = ViewToWorld(viewPos);

  gl_Position = ftransform();
}

#endif // VSH