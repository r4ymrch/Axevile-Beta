#include "/lib/config.glsl"

#ifdef FSH

// Varyings
varying vec2 texCoord;
varying float dayMixer, nightMixer;
varying vec3 sunVec, lightVec;

// Uniforms
uniform sampler2D noisetex;
uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

uniform float aspectRatio;
uniform float rainStrength;
uniform float viewWidth, viewHeight;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

// Common functions
#include "/lib/utility.glsl"
#include "/lib/encoding.glsl"
#include "/lib/ambientOcclusion.glsl"
#include "/lib/shadows.glsl"

const vec3 cfgEnvDayColor = vec3(CFG_ENV_DAY_COLOR_CR, CFG_ENV_DAY_COLOR_CG, CFG_ENV_DAY_COLOR_CB) * CFG_ENV_DAY_COLOR_CA;
const vec3 cfgEnvSunColor = vec3(CFG_ENV_SUN_COLOR_CR, CFG_ENV_SUN_COLOR_CG, CFG_ENV_SUN_COLOR_CB) * CFG_ENV_SUN_COLOR_CA;
const vec3 cfgEnvNightColor = vec3(CFG_ENV_NIG_COLOR_CR, CFG_ENV_NIG_COLOR_CG, CFG_ENV_NIG_COLOR_CB) * CFG_ENV_NIG_COLOR_CA;
const vec3 cfgShdDayColor = vec3(CFG_SHD_DAY_COLOR_CR, CFG_SHD_DAY_COLOR_CG, CFG_SHD_DAY_COLOR_CB) * CFG_SHD_DAY_COLOR_CA;
const vec3 cfgShdSunColor = vec3(CFG_SHD_SUN_COLOR_CR, CFG_SHD_SUN_COLOR_CG, CFG_SHD_SUN_COLOR_CB) * CFG_SHD_SUN_COLOR_CA;
const vec3 cfgShdNightColor = vec3(CFG_SHD_NIG_COLOR_CR, CFG_SHD_NIG_COLOR_CG, CFG_SHD_NIG_COLOR_CB) * CFG_SHD_NIG_COLOR_CA;
const vec3 cfgBlockLightColor = vec3(CFG_UV_COLOR_CR, CFG_UV_COLOR_CG, CFG_UV_COLOR_CB) * CFG_UV_COLOR_CA;

vec3 WorldToShadow(vec3 worldPos) {
	vec3 pos = mat3(shadowModelView) * worldPos + shadowModelView[3].xyz;
	return ProjMAD(shadowProjection, pos);
}

// Main program
void main() {
  vec3 color = texture2D(colortex0, texCoord).rgb;
  
  vec2 lightmap = texture2D(colortex1, texCoord).rg;
  vec3 normal = DecodeNormal(texture2D(colortex2, texCoord).rg);
  
  float NdotL = texture2D(colortex2, texCoord).b;
  float depth = texture2D(depthtex0, texCoord).r;
  
  bool sky = depth == 1.0;
  bool terrain = depth < 1.0;

  vec3 screenPos = vec3(texCoord, depth);
	vec3 viewPos = Mat4x4Vec3_To_Vec3(gbufferProjectionInverse, screenPos * 2.0 - 1.0);
  vec3 worldPos = Mat4x4Vec3_To_Vec3(gbufferModelViewInverse, viewPos);

  vec3 worldNormal = mat3(gbufferModelViewInverse) * normal;
  
  float distb = sqrt(dot(worldPos, worldPos));
  vec3 bias = worldNormal * min(0.06 + distb * 0.005, 0.5) * (2.0 - max(NdotL, 0.0));	

  // worldPos += bias;
  vec3 shadowPos = WorldToShadow(worldPos + bias);

  distb = sqrt(dot(shadowPos.xy, shadowPos.xy));
  float distortFactor = distb * SHADOW_MAP_BIAS + (1.0 - SHADOW_MAP_BIAS);

  shadowPos.xy /= distortFactor;
  shadowPos.z *= 0.2;
  shadowPos = shadowPos * 0.5 + 0.5;

  float aoDither = texture2D(noisetex, gl_FragCoord.xy / float(noiseTextureResolution)).b;
  if (terrain) color *= AmbientOcclusion(aoDither);

  #ifdef SHADOW_SUBSURFACE
    float PdistS = distance(normalize(worldPos), mat3(gbufferModelViewInverse) * sunVec);
    float PdistM = distance(normalize(worldPos), mat3(gbufferModelViewInverse) * -sunVec);
    
    float subsurfaceSun = exp(-length(PdistS) * SSUBSURFACE_SCALE) * SSUBSURFACE_INTENSITY * (1.0 - nightMixer);
    float subsurfaceMoon = exp(-length(PdistM) * (SSUBSURFACE_SCALE + 1.0)) * SSUBSURFACE_INTENSITY * nightMixer;
    
    float subsurface = subsurfaceSun + subsurfaceMoon;
  #endif

  vec3  sunLight = mix(cfgEnvSunColor * 1.5, cfgEnvDayColor, dayMixer);
        sunLight = mix(sunLight, cfgEnvNightColor, nightMixer);
  
  #ifdef SHADOW_SUBSURFACE
    sunLight = mix(sunLight, sunLight * 3.14, subsurface);
  #endif

  sunLight *= NdotL;

  #if SHADOW_MAP_TYPE > 0
    sunLight *= GetShadows(shadowPos);
  #endif

  sunLight *= (1.0 - rainStrength);

  float noShadowTime = 1.0 - max(
    clamp(dot(sunVec, normalize(gbufferModelView[1].xyz)) * 2.0, 0.0, 1.0), 
    clamp(dot(-sunVec, normalize(gbufferModelView[1].xyz)) * 6.0, 0.0, 1.0)
  );

  sunLight = mix(sunLight, vec3(0.0), noShadowTime);

  vec3  skyLight = mix(cfgShdSunColor, cfgShdDayColor, dayMixer);
        skyLight = mix(skyLight, cfgShdNightColor, nightMixer);
        skyLight = mix(skyLight, skyLight * vec3(0.65, 0.8, 1.0) * 1.6, rainStrength);
        skyLight *= SHADOW_BRIGHTNESS;
        skyLight *= pow(lightmap.y, 6.0);

  vec3  blockLight = vec3(1.0, 0.9, 0.8) * 0.2 * lightmap.x * lightmap.y;
        blockLight += vec3(1.0, 0.9, 0.8) * 0.4 * pow(lightmap.x, 3.0) * lightmap.y;
        blockLight += vec3(1.0, 0.9, 0.8) * 0.4 * pow(lightmap.x, 6.0) * lightmap.y;
        blockLight += vec3(1.0, 0.9, 0.8) * 0.6 * pow(lightmap.x, 8.0);
        blockLight += cfgBlockLightColor * mix(4.0, 8.0, lightmap.y) * pow(lightmap.x, 24.0);

  color = color * (sunLight + skyLight + blockLight);

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