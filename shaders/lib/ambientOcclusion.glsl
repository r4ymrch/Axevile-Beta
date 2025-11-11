float GetLinearDepth(float depth, mat4 invProjMatrix) {
  depth = depth * 2.0 - 1.0;
  vec2 zw = depth * invProjMatrix[2].zw + invProjMatrix[3].zw;
  return -zw.x / zw.y;
}

// Based on Capt Tatsu's ambient occlusion functions.
float AmbientOcclusion(float dither) {
	float depth = texture2D(depthtex0, texCoord).r;
	if(depth >= 1.0) return 1.0;
	
	float linearZ = GetLinearDepth(depth, gbufferProjectionInverse);
  float distanceScale = max(linearZ, 2.5);
	
	vec2 scale = AO_RADIUS * vec2(1.0 / aspectRatio, 1.0) * (gbufferProjection[1][1] / 1.37) / distanceScale;
	float differenceScale = linearZ / distanceScale;
	float mult = (0.7 / AO_RADIUS);

	float ao = 0.0;
  float currentStep = 0.2475 * dither + 0.01;
	vec2 baseOffset = vec2(cos(dither * 6.28), sin(dither * 6.28));
	for (int i = 0; i < 4; i++) {
		vec2 offset = baseOffset * currentStep * scale;

    float angle = 0.0; 
    float dist = 0.0;
		for (int i = 0; i < 2; i++) {
			float sampleDepth = GetLinearDepth(texture2D(depthtex0, texCoord + offset).r, gbufferProjectionInverse);
			float aoSample = (linearZ - sampleDepth) * mult / currentStep;

			angle += clamp(0.5 - aoSample, 0.0, 1.0);
			dist += clamp(0.25 * aoSample - 1.0, 0.0, 1.0);
			offset = -offset;
		}

		ao += clamp(angle + dist, 0.0, 1.0);
		currentStep += 0.2475;
		baseOffset = vec2(baseOffset.x - baseOffset.y, baseOffset.x + baseOffset.y) * 0.7071;
	}

	return mix(1.0, ao * 0.25, AO_STRENGTH);	
}
