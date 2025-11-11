vec3 DrawSkyAndFog(vec3 color, vec3 worldPos, bool isSky) {
  float density = 5.0;
  float ground = length(worldPos) / far;
  ground = clamp(ground, 0.0, 1.0);
  ground = pow(ground, mix(density, density * 0.5, nightMixer));

  float fog = length(worldPos) * (256.0 * 0.0001);
  fog = clamp(fog, 0.0, 1.0) * 0.3;
    
  vec3 zenithColor = CalcSky(vec3(0.0, 1.0, 0.0), false);
  zenithColor = mix(zenithColor, zenithColor * 1.5, nightMixer);
  zenithColor = SRGBToLinear(zenithColor);

  vec3 fogColor = CalcSky(normalize(worldPos), isSky);
  fogColor = SRGBToLinear(fogColor);

  color = mix(color, zenithColor, fog);
  color = mix(color, fogColor, ground);

  return color;
}
