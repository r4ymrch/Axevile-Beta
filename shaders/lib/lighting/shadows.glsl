/*
- Axevile v1.0.0 - shadow program.
- See README.md for more details.
*/

#define FILTERED_SHADOWS
#define COLORED_SHADOWS

uniform sampler2DShadow shadowtex0;
uniform sampler2DShadow shadowtex1;
uniform sampler2D shadowcolor0;

const float invShadowRes = 0.000651041667;

#ifdef FILTERED_SHADOWS
  vec2 shadowOffsets[8] = vec2[8](
    vec2( 0.0, 0.0),
    vec2( 0.0, 1.0),
    vec2( 0.5, 0.5),
    vec2( 1.0, 0.0),
    vec2( 0.5,-0.5),
    vec2( 0.0,-1.0),
    vec2(-0.5,-0.5),
    vec2(-1.0, 0.0)
  );

  vec2 GetSampleOffset(int i, float blurRadius) {
    float blueNoise = texture2D(noisetex, gl_FragCoord.xy * invNoiseResolution).b;
	  return Rotate2D(blueNoise * TAU) * shadowOffsets[i] * blurRadius;
  }
#endif

float GetBasicShadow(sampler2DShadow shadowTex, vec3 shadowPos) {
	return shadow2D(shadowTex, shadowPos).x;
}

#ifdef FILTERED_SHADOWS
  float GetFilteredShadow(sampler2DShadow shadowTex, vec3 shadowPos, float blurRadius) {
    float shadowMap = 0.0;
    for (int i = 0; i < 4; i++) {
      vec2 sampleOffset = GetSampleOffset(i, blurRadius);
      shadowMap += GetBasicShadow(shadowTex, vec3(shadowPos.xy + sampleOffset, shadowPos.z));
    }
    return shadowMap * 0.25;
  }
#endif

vec3 GetShadows(vec3 worldPos, vec3 normal, float NoL) {
	vec3 worldNormal = ToWorldSpace(normal);

	float dist = sqrt(dot(worldPos, worldPos));
  vec3 bias = worldNormal * min(0.06 + dist * 0.005, 0.5) * (2.0 - max(NoL, 0.0));	

  worldPos += bias;

  vec3  shadowPos = ToShadowSpace(worldPos);
        shadowPos = DistortShadow(shadowPos);
        shadowPos = shadowPos * 0.5 + 0.5;

	float blurRadius = 2.0 * invShadowRes;
  float shadowMap0 = 1.0;
  float shadowMap1 = 1.0;

  #ifdef COLORED_SHADOWS
    #ifdef FILTERED_SHADOWS
      shadowMap0 = GetFilteredShadow(shadowtex0, shadowPos, blurRadius);
      shadowMap1 = GetFilteredShadow(shadowtex1, shadowPos, blurRadius);
    #else
      shadowMap0 = GetBasicShadow(shadowtex0, shadowPos);
      shadowMap1 = GetBasicShadow(shadowtex1, shadowPos);
    #endif

    vec4 shadowColor = texture2D(shadowcolor0, shadowPos.xy);
    if (shadowMap0 < 1.0) shadowColor.rgb = texture2D(shadowcolor0, shadowPos.xy).rgb * shadowMap1;
    
    shadowColor.rgb = mix(vec3(1.0), shadowColor.rgb, pow(shadowColor.a, 0.5));
    shadowColor.rgb *= shadowColor.rgb;

    return saturate(shadowColor.rgb * (1.0 - shadowMap0) + shadowMap0);
  #else
    #ifdef FILTERED_SHADOWS
      shadowMap0 = GetFilteredShadow(shadowtex0, shadowPos, blurRadius);
    #else
      shadowMap0 = GetBasicShadow(shadowtex0, shadowPos);
    #endif

    return vec3(shadowMap0);
  #endif
}