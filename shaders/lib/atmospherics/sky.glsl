/*
- Axevile v1.0.0 - sky functions.
- See README.md for more details.
*/

float fogify(float x, float w) {
	return w / (x * x + w);
}

float GetMiePhase(float mu, float g) {
  float mu2 = pow2(mu);
	float g2 = pow2(g);
  float x = 1.0 + g2 - 2.0 * mu * g;

  float denom = x * sqrt(x) * (2.0 + g2);
  const float k = 3.0 / (8.0 * PI);
  
  return k * ((1.0 - g2) * (mu2 + 1.0)) / denom;
}

vec4 CalcSky(vec3 position, bool sky) {
	float VoU = dot(position, upVector);
  float VoL = dot(position, sunVector);
	float VoM = dot(position, -sunVector);

	float zenith = fogify(max(VoU, 0.0), 1.5 * ZENITH_DENSITY);
	float horizon = fogify(max(VoU + 0.15, 0.0), 0.05 * HORIZON_DENSITY_MULTIPLIER);
	
  float halos = exp(-length(distance(position, sunVector) * 0.2));
	float skyMixer = smoothstep(1.0, 0.35, distance(position, sunVector) * 0.45);
        skyMixer = mix(skyMixer, halos, dayTime);
        skyMixer = mix(skyMixer, 0.0, nightTime);

	float starAlpha = 0.0; 
  #ifdef STARS
    starAlpha = mix(1.0 * STARS_BRIGHTNESS_MULTIPLIER, 0.0, max(skyMixer, horizon));
    starAlpha = mix(starAlpha, 0.0, dayTime);
  #endif

	vec3 daySky = mix(vec3(0) + skyColor * zenith, fogColor, horizon);
	vec3 nightSky = mix(vec3(0) + nightColor * 0.8 * zenith, nightColor * 1.5, horizon);
	vec3 totalSky = mix(nightSky * 0.9, daySky, skyMixer);

  vec3 mieSun = fogColor * PI * (
    (GetMiePhase(VoL, MIE_PHASE_G) * 0.05 * MIE_STRENGTH_MULTIPLIER) + 
    (GetMiePhase(VoL, MIE_PHASE_G2) * 0.015 * MIE_STRENGTH_MULTIPLIER * float(sky))
  ) * (1.0 - nightTime);
  
  vec3 mieMoon = nightColor * (
    (GetMiePhase(VoM, MIE_PHASE_G) * 0.5 * MIE_STRENGTH_MULTIPLIER) + 
    (GetMiePhase(VoM, MIE_PHASE_G2) * 0.035 * MIE_STRENGTH_MULTIPLIER * float(sky))
  ) * nightTime;

  totalSky += (mieSun + mieMoon) * (1.0 - rainStrength);

	vec3 rainColor = vec3(GetLuminance(totalSky)) * vec3(0.65, 0.8, 1.0);
	totalSky = mix(totalSky, rainColor, rainStrength);

	return vec4(totalSky, starAlpha);
}