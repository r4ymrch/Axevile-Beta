/*
====================================================
- Axevile shaders v1.0.0 developed and maintaned by r4ymrch.
- See README.md for more details about this shaders.
- Last modified : 11/18/2025.
====================================================
*/

#define SSAO_RADIUS 0.25

float GetLinearDepth(float depth) {
  depth = depth * 2.0 - 1.0;
  vec2 zw = depth * gbufferProjectionInverse[2].zw + gbufferProjectionInverse[3].zw;
  return -zw.x / zw.y;
}

// Based from Capt Tatsu Ambient Occlusion functions.
float CalcSSAO(float dither) {
	float z = texture2D(depthtex0, texCoord).r;
	if(z >= 0.999) return 1.0;
	
	float linearZ = GetLinearDepth(z);
  float distanceScale = max(linearZ, 2.5); 
	float mult = (0.7 / SSAO_RADIUS);
  
	vec2 scale = SSAO_RADIUS * vec2(1.0 / aspectRatio, 1.0) * (gbufferProjection[1][1] / 1.37) / distanceScale;
  vec2 baseOffset = vec2(cos(dither * 6.28318530717959), sin(dither * 6.28318530717959));
  
  const float stepMultiplier = 0.2475;
  const float stepInitial = 0.01;

	float ao = 0.0;
	for (int i = 0; i < 4; i++) {
    float currentStep = stepMultiplier * float(i) + stepInitial;		
		vec2 offset = baseOffset * currentStep * scale;

    float angle = 0.0; 
    float dist = 0.0;
		for (int j = 0; j < 2; j++) {
			float sampleDepth = GetLinearDepth(texture2D(depthtex0, texCoord + offset).r);
      float deltaZ = linearZ - sampleDepth;
			float aoSample = deltaZ * mult / currentStep; 

			angle += clamp01(0.5 - aoSample);
			dist += clamp01(0.25 * aoSample - 1.0);
			offset = -offset;
		}
		
		ao += clamp01(angle + dist);
		
		baseOffset = vec2(baseOffset.x - baseOffset.y, baseOffset.x + baseOffset.y) * 0.7071;
	}

	return mix(clamp01(ao * 0.25), 1.0, 0.5);
}