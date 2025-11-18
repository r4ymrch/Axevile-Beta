/*
====================================================
- Axevile shaders v1.0.0 developed and maintaned by r4ymrch.
- See README.md for more details about this shaders.
- Last modified : 11/18/2025.
====================================================
*/

vec3 Distort(vec3 fragPos) {
	float centerDist = sqrt(dot(fragPos.xy, fragPos.xy));
  float distortFactor = centerDist * SHADOW_BIAS + (1.0 - SHADOW_BIAS);

  fragPos.xy /= distortFactor;
  fragPos.z *= 0.2;

	return fragPos;
}