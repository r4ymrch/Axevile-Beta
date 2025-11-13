float fogify(float x, float w) {
	return w / (x * x + w);
}

float PhaseMie(float mu, float g) {
  float mu2 = mu * mu;
	float gg = g * g;
  float x = 1.0 + gg - 2.0 * mu * g;

  float denom = x * sqrt(x) * (2.0 + gg);
  const float k = 3.0 / (8.0 * 3.14);
  
  return k * ((1.0 - gg) * (mu2 + 1.0)) / denom;
}

vec4 CalcSky(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	float lightDot = distance(pos, sunVector);

	float zenith = fogify(max(upDot, 0.0), 1.5);
	float horizon = fogify(max(upDot + 0.1, 0.0), 0.075);
	
	float skyMixer = smoothstep(1.0, 0.35, lightDot * 0.45);
  skyMixer = mix(skyMixer, exp(-length(lightDot * 0.2)), dayTime);
  skyMixer = mix(skyMixer, 0.0, nightTime);

	float starAlpha = mix(9.0, 0.0, max(skyMixer, horizon));
	starAlpha = mix(starAlpha, 0.0, dayTime);

	vec3 daySky = mix(vec3(0) + skyColor * zenith, fogColor, horizon);
	vec3 nightSky = mix(vec3(0) + nightColor * 0.65 * zenith, nightColor * 1.5, horizon);
	vec3 totalSky = mix(nightSky * 0.9, daySky, skyMixer);

	float PdotS = dot(pos, sunVector);
	float PdotM = dot(pos, -sunVector);

	vec3 mieSun = fogColor * 3.0 * PhaseMie(PdotS, 0.95) * 0.015;
  vec3 mieSun2 = fogColor * 3.0 * PhaseMie(PdotS, 0.65) * 0.1;
  mieSun *= (1.0 - nightTime);
  mieSun2 *= (1.0 - nightTime);
  
  vec3 mieMoon = nightColor * PhaseMie(PdotM, 0.65) * 0.25 * nightTime;
  vec3 mieMoon2 = nightColor * PhaseMie(PdotM, 0.95) * 0.035 * nightTime;
  
  vec3 miePhase = mieSun + mieMoon + mieSun2 + mieMoon2;
  miePhase *= (1.0 - rainStrength);
  
  totalSky += miePhase;

	float grayscale = GetLuminance(totalSky);
	totalSky = mix(totalSky, vec3(grayscale) * vec3(0.65, 0.8, 1.0), rainStrength);

	return vec4(totalSky, starAlpha);
}
