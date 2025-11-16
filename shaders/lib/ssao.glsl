#define AO_RADIUS 0.25

float GetLinearDepth(float depth, mat4 invProjMatrix) {
  depth = depth * 2.0 - 1.0;
  vec2 zw = depth * invProjMatrix[2].zw + invProjMatrix[3].zw;
  return -zw.x / zw.y;
}

float AmbientOcclusion(float dither) {
	float z = texture2D(depthtex0, texCoord).r;
	if(z >= 0.999) return 1.0;
	
	float linearZ = GetLinearDepth(z, gbufferProjectionInverse);
  float distanceScale = max(linearZ, 2.5); 
	float mult = (0.7 / AO_RADIUS);
  
	vec2 scale = AO_RADIUS * vec2(1.0 / aspectRatio, 1.0) * (gbufferProjection[1][1] / 1.37) / distanceScale;
  vec2 baseOffset = vec2(cos(dither * 6.28318), sin(dither * 6.28318));
  
  const float stepMultiplier = 0.2475;
  const float stepInitial = 0.01;

	float ao = 0.0;
	for (int i = 0; i < 4; i++) {
    float currentStep = stepMultiplier * float(i) + stepInitial;		
		vec2 offset = baseOffset * currentStep * scale;

    float angle = 0.0; 
    float dist = 0.0;
		for (int j = 0; j < 2; j++) {
			float sampleDepth = GetLinearDepth(texture2D(depthtex0, texCoord + offset).r, gbufferProjectionInverse);
      float deltaZ = linearZ - sampleDepth;
			float aoSample = deltaZ * mult / currentStep; 

			angle += clamp(0.5 - aoSample, 0.0, 1.0);
			dist += clamp(0.25 * aoSample - 1.0, 0.0, 1.0);
			offset = -offset;
		}
		
		ao += clamp(angle + dist, 0.0, 1.0);
		
		baseOffset = vec2(baseOffset.x - baseOffset.y, baseOffset.x + baseOffset.y) * 0.7071;
	}

	return clamp(ao * 0.25, 0.0, 1.0);	
}