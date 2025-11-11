#ifdef USE_SHADOW_HARDWARE_FILTERING
  uniform sampler2DShadow shadowtex0;

  #if SHADOW_MAP_TYPE == 3
    uniform sampler2D shadowtex1;
  #else
    uniform sampler2DShadow shadowtex1;
  #endif
  
  const bool shadowHardwareFiltering = true;
#else
  uniform sampler2D shadowtex0;
  uniform sampler2D shadowtex1;
#endif

#ifdef COLORED_SHADOWS
  uniform sampler2D shadowcolor0;
#endif

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
  float blueNoise = texture2D(noisetex, gl_FragCoord.xy / float(noiseTextureResolution)).b;
	return Rotate2D(blueNoise * 6.28318531) * shadowOffsets[i] * blurRadius;
}

float GetBasicShadow(sampler2D shadowTex, vec3 shadowPos) {
  return step(shadowPos.z, texture2D(shadowTex, shadowPos.xy).x);
}

float GetBasicShadow(sampler2DShadow shadowTex, vec3 shadowPos) {
  return shadow2D(shadowTex, shadowPos).x;
}

float GetFilteredShadow(sampler2D shadowTex, vec3 shadowPos, float blurRadius) {
  float shadowMap = 0.0;
  for (int i = 0; i < PCF_SHADOW_SAMPLES; i++) {
    vec2 sampleOffset = GetSampleOffset(i, blurRadius);
    shadowMap += GetBasicShadow(shadowTex, vec3(shadowPos.xy + sampleOffset, shadowPos.z));
  }
  return shadowMap / float(PCF_SHADOW_SAMPLES);
}

float GetFilteredShadow(sampler2DShadow shadowTex, vec3 shadowPos, float blurRadius) {
  float shadowMap = 0.0;
  for (int i = 0; i < PCF_SHADOW_SAMPLES; i++) {
    vec2 sampleOffset = GetSampleOffset(i, blurRadius);
    shadowMap += GetBasicShadow(shadowTex, vec3(shadowPos.xy + sampleOffset, shadowPos.z));
  }
  return shadowMap / float(PCF_SHADOW_SAMPLES);
}

#if SHADOW_MAP_TYPE == 3
  float FindBlocker(vec3 shadowPos) {
    float blocker = 0.0;
    float numBlocker = 0.0;
    float penumbraRad = PCSS_BLUR_RADIUS * 0.01;
    
    for (int i = 0; i < PCSS_SHADOW_SAMPLES; ++i) {
      vec2 sampleOffset = GetSampleOffset(i, penumbraRad);
      float shadowDepth = texture2D(shadowtex1, shadowPos.xy + sampleOffset).x;
      
      if (shadowDepth < shadowPos.z) {
        blocker += shadowDepth;
        numBlocker++;
      }
    }
    
    blocker /= numBlocker;
    blocker = (shadowPos.z - blocker) / blocker;

    return clamp(blocker, 0.0, 1.0);
  }
#endif

vec3 GetShadows(vec3 shadowPos) {
  float blurRadius = PCF_BLUR_RADIUS / float(shadowMapResolution);
  
  #if SHADOW_MAP_TYPE == 3
    float blocker = FindBlocker(shadowPos);
    blurRadius = max(blurRadius * 0.3, blocker * 0.4);
  #endif

  float shadowMap0 = 1.0;
  float shadowMap1 = 1.0;
  
  #if SHADOW_MAP_TYPE == 1
    shadowMap0 = GetBasicShadow(shadowtex0, shadowPos);
    shadowMap1 = GetBasicShadow(shadowtex1, shadowPos);
  #elif SHADOW_MAP_TYPE == 2 || SHADOW_MAP_TYPE == 3
    shadowMap0 = GetFilteredShadow(shadowtex0, shadowPos, blurRadius);
    shadowMap1 = GetFilteredShadow(shadowtex1, shadowPos, blurRadius);
  #endif

  #ifdef COLORED_SHADOWS
    vec4  coloredShadow = texture2D(shadowcolor0, shadowPos.xy);
          coloredShadow.rgb = mix(vec3(1.0), coloredShadow.rgb, pow(coloredShadow.a, 0.05));
	
    return coloredShadow.rgb * (shadowMap1 - shadowMap0) + shadowMap0;
  #else
    return vec3(shadowMap0);
  #endif
}
