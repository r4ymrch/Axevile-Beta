/*
- Axevile v1.0.0 - light shaft functions.
- See README.md for more details.
*/

uniform sampler2DShadow shadowtex1;

vec3 GetLightShaftPos(vec3 worldPos) {
  vec3 position = ToShadowSpace(worldPos);

  float distb = sqrt(dot(position.xy, position.xy));
  float distortFactor = distb * SHADOW_BIAS + (1.0 - SHADOW_BIAS);

  position.xy /= distortFactor;
  position.z *= 0.2;
  
  return position * 0.5 + 0.5;
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

    vec3 viewPos = ToViewSpace(vec3(texCoord, currentDepth));
    vec3 worldPos = ToWorldSpace(viewPos);

    vec3 lightShaftPos = ToShadowSpace(worldPos);
    lightShaftPos = DistortShadow(lightShaftPos);
    lightShaftPos = lightShaftPos * 0.5 + 0.5;

    lightShaft += shadow2D(shadowtex1, lightShaftPos).x;
  }

  return saturate(lightShaft * 0.25);
}