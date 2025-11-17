/*
- Axevile v1.0.0 - distort functions.
- See README.md for more details.
*/

vec3 DistortShadow(vec3 shadowPos) {
	float dist = sqrt(dot(shadowPos.xy, shadowPos.xy));
  float distortFactor = dist * SHADOW_BIAS + (1.0 - SHADOW_BIAS);

  shadowPos.xy /= distortFactor;
  shadowPos.z *= 0.2;

	return shadowPos;
}