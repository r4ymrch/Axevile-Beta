/*
- Axevile v1.0.0 - fog functions.
- See README.md for more details.
*/

float GetFogFactor(vec3 viewPos, float depth) {
	if (depth == 1.0) return 0.0;
	
	float density = mix(5.0, 3.0, nightTime);
        density = mix(density, 4.0, rainStrength);

	float dist = length(viewPos) / far;
	float fogFactor = exp(-density * (1.0 - dist));
        fogFactor = clamp(fogFactor, 0.0, 1.0);

	return fogFactor;
}