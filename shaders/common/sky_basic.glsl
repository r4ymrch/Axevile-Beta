#ifdef FSH

varying vec3 sunVec;
varying vec3 viewPos;
varying vec3 worldPos;

uniform float dayTime;
uniform float nightTime;

uniform mat4 gbufferModelViewInverse;

#include "/lib/utils.glsl"
#include "/lib/sky.glsl"

void main()
{
  vec3 outColor = CalcSky(normalize(worldPos));
  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(sRGBToLinear(outColor), 1.0);
}

#endif // FSH

#ifdef VSH

varying vec3 viewPos;
varying vec3 worldPos;
varying vec3 sunVec;

uniform float timeAngle;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

void main()
{
  viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	worldPos = mat3(gbufferModelViewInverse) * viewPos + gbufferModelViewInverse[3].xyz;

  #include "/src/sunVector.glsl"

  gl_Position = ftransform();
}

#endif // FSH