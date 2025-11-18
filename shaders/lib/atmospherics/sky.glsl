/*
====================================================
- Axevile shaders v1.0.0 developed and maintaned by r4ymrch.
- See README.md for more details about this shaders.
- Last modified : 11/18/2025.
====================================================
*/

float GetMiePhase(float mu, float g) {
  float mu2 = pow2(mu);
	float g2 = pow2(g);
  float x = 1.0 + g2 - 2.0 * mu * g;

  float denom = x * sqrt(x) * (2.0 + g2);
  const float k = 0.119366; // 3.0 / (8.0 * 3.14159265358979);
  
  return k * ((1.0 - g2) * (mu2 + 1.0)) / denom;
}

vec4 CalcSky(vec3 position, bool sky) {
	float VoU = dot(position, upVector);
  float VoL = dot(position, sunVector);
	float VoM = dot(position, -sunVector);

	float zenith = fogify(max(VoU, 0.0), 1.5 * ZENITH_DENSITY_MULTIPLIER);
	float horizon = fogify(max(VoU + 0.15, 0.0), 0.05 * HORIZON_DENSITY_MULTIPLIER);
	
  float distToSun = distance(position, sunVector);
  float skyMixer = smoothstep(1.0, 0.35, distToSun * 0.5);
  float halos = exp(-distToSun * 0.2);
  
  skyMixer = skyMixer * (1.0 - dayTime) + halos * dayTime;
  skyMixer *= (1.0 - nightTime);

	float starAlpha = 0.0; 
  #ifdef STARS
    float brightness = 1.0 * STARS_BRIGHTNESS_MULTIPLIER;
    float fadeOut = max(skyMixer, horizon);

    starAlpha = brightness * (1.0 - fadeOut) * (1.0 - dayTime);
  #endif

  vec3 dayBase = vec3(0) + skyColor * zenith;
  vec3 daySky = mix(dayBase, fogColor, horizon);

  vec3 nightBase = vec3(0) + nightColor * 0.8 * zenith;
  vec3 nightSky = mix(nightBase, nightColor * 1.5, horizon) * 0.9;

  vec3 totalSky = mix(nightSky, daySky, skyMixer);

  vec3 mieSun = fogColor * 3.14159265358979 * (
    (
      GetMiePhase(VoL, MIE_PHASE_G) * 0.05 + 
      GetMiePhase(VoL, MIE_PHASE_G2) * 0.015 * float(sky)
    )
  ) * MIE_STRENGTH_MULTIPLIER * (1.0 - nightTime);
  
  vec3 mieMoon = nightColor * (
    (
      GetMiePhase(VoM, MIE_PHASE_G) * 0.5 + 
      GetMiePhase(VoM, MIE_PHASE_G2) * 0.035 * float(sky)
    )
  ) * MIE_STRENGTH_MULTIPLIER * nightTime;
  
  vec3 totalMie = (mieSun + mieMoon) * (1.0 - rainStrength);

  totalSky += totalMie;

  if (rainStrength > 0.0) {
	  vec3 rainColor = vec3(Luminance(totalSky)) * vec3(0.65, 0.8, 1.0);
    totalSky = mix(totalSky, rainColor, rainStrength);
  }

	return vec4(totalSky, starAlpha);
}