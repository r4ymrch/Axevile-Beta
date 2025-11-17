/*
- Axevile v1.0.0 - source code.
- See README.md for more details.
*/

float VoLSun = distance(normalize(viewPos), sunVector);
float VoLMoon = distance(normalize(viewPos), -sunVector);

float sunVisibility = clamp(dot(sunVector, upVector) * 24.0, 0.0, 1.0);
float sunLSVisibility = exp(-length(VoLSun) * 3.0) * sunVisibility;
float moonLSVisibility = exp(-length(VoLMoon) * 1.5) * (1.0 - sunVisibility);
	
float lsVisibility = sunLSVisibility + moonLSVisibility;
			lsVisibility = clamp(lsVisibility, 0.0, 1.0);

float blueNoise = texture2D(noisetex, gl_FragCoord.xy * invNoiseResolution).b;
float baseLightShaft = GetLightShaft(blueNoise);
			baseLightShaft *= (1.0 - rainStrength);
	
float intensity = mix(0.3, 0.15, dayTime);
			intensity = mix(intensity, 0.25, nightTime);

vec3 lightShaftColor = mix(fogColor, nightColor * 1.5, nightTime);
lightShaftColor = pow(lightShaftColor, vec3(2.2)) * baseLightShaft;
	
outColor = mix(outColor, lightShaftColor, baseLightShaft * intensity * lsVisibility);