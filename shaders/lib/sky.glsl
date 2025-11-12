vec3 skyColor = mix(vec3(0.3, 0.5, 1.0) * 0.75, vec3(0.3, 0.5, 1.0), dayTime);
vec3 fogColor = mix(vec3(1.0, 0.8, 0.6) * 1.5, vec3(0.9, 0.95, 1.0), dayTime);
vec3 nightColor = vec3(0.2, 0.2, 0.3);

float PhaseMie(float mu, float g) {
  float mu2 = mu * mu;
	float gg = g * g;
  float x = 1.0 + gg - 2.0 * mu * g;

  float denom = x * sqrt(x) * (2.0 + gg);
  const float k = 3.0 / (8.0 * 3.14);
  
  return k * ((1.0 - gg) * (mu2 + 1.0)) / denom;
}

float fogify(float y, float x) {
  return x / (y * y + x);
}

vec3 CalcDaySky(vec3 worldPos) {
  worldPos.y += 0.1;
  if (worldPos.y < 0.0) return fogColor;
  
  float zenith = fogify(worldPos.y, 3.0);
  float horizon = fogify(worldPos.y, 0.15);
  
  return mix(vec3(0) + skyColor * zenith, fogColor, horizon);
}

vec3 CalcNightSky(vec3 worldPos) {
  if (worldPos.y < 0.0) return nightColor * 1.5;
  float horizon = fogify(worldPos.y, 0.2);
  return mix(nightColor, nightColor * 1.5, horizon);
}

vec3 CalcSky(vec3 worldPos) {
  vec3 worldSunVec = mat3(gbufferModelViewInverse) * sunVec;

  float PdotL = dot(worldPos, worldSunVec);
  float PdistL = distance(worldPos, worldSunVec);
  
  float skyMixer = exp(-length(PdistL * 0.8)) * 1.5;
  skyMixer = mix(skyMixer, exp(-length(PdistL * 0.2)) * 1.5, dayTime);
  skyMixer = mix(skyMixer, 0.0, nightTime);

  vec3 daySky = CalcDaySky(worldPos);
  vec3 nightSky = CalcNightSky(worldPos);
  
  return mix(nightSky, daySky, skyMixer);
}