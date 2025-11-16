uniform sampler2DShadow shadowtex1;

vec3 GetLightShaftPos(vec3 worldPos) {
  vec3 pos = mat3(shadowModelView) * worldPos + shadowModelView[3].xyz;
  pos = ProjMAD(shadowProjection, pos);

  float distb = sqrt(dot(pos.xy, pos.xy));
  float distortFactor = distb * SHADOW_MAP_BIAS + (1.0 - SHADOW_MAP_BIAS);

  pos.xy /= distortFactor;
  pos.z *= 0.2;
  
  return pos * 0.5 + 0.5;
}

float GetLightShaft(float dither) {
  float depth = texture2D(depthtex0, texCoord).r;
  float linearDepth = (2.0 * near) / (far + near - depth * (far - near));
  float viewDistance = linearDepth * far * 0.5;
  
  float lightShaft = 0.0;
  for (int i = 0; i < 4; i++) {
    float currentDepth = exp2(i + dither) - 0.5;
    if (currentDepth > viewDistance) break;
    
    currentDepth = (far * (currentDepth - near)) / (currentDepth * (far - near));

    vec3 viewPos = toViewSpace(vec3(texCoord, currentDepth));
    vec3 worldPos = toWorldSpace(viewPos);
    vec3 lightShaftPos = GetLightShaftPos(worldPos);

    lightShaft += shadow2D(shadowtex1, lightShaftPos).x;
  }

  return lightShaft * 0.25;
}