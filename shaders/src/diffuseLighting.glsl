/*
- Axevile v1.0.0 - source code.
- See README.md for more details.
*/

float transition = 1.0 - max(
  clamp(dot(sunVector, upVector) * 24.0, 0.0, 1.0), 
  clamp(dot(-sunVector, upVector) * 6.0, 0.0, 1.0)
);

float PdistS = distance(normalize(viewPos), sunVector);
float PdistM = distance(normalize(viewPos), -sunVector);
    
float subsurfaceSun = exp(-length(PdistS) * 4.0) * 6.0 * (1.0 - nightTime);
float subsurfaceMoon = exp(-length(PdistM) * 4.0) * 6.0 * nightTime;
float subsurface = subsurfaceSun + subsurfaceMoon;

vec3  sunLight = mix(vec3(1.0, 0.5, 0.0), fogColor, dayTime);
      sunLight = mix(sunLight, nightColor * 0.25, nightTime);
      sunLight = mix(sunLight, sunLight * 2.0, subsurface);
      
sunLight *= lmCoord.y * normalBuffer.z;
sunLight *= GetShadows(worldPos, normal, normalBuffer.z);

sunLight *= (1.0 - rainStrength);
sunLight = mix(sunLight, vec3(0.0), transition);

vec3  skyLight = mix(nightColor, skyColor * 0.75, dayTime);
      skyLight = mix(skyLight, nightColor * 0.5, nightTime);
      skyLight = mix(skyLight, skyLight * 1.35, rainStrength);

skyLight = mix(skyLight, nightColor * 0.75, transition);
skyLight *= pow(lmCoord.y, 3.0);

vec3  blockLight = vec3(1.0, 0.9, 0.8) * 0.2 * lmCoord.x * lmCoord.y;
      blockLight += vec3(1.0, 0.9, 0.8) * 0.4 * pow(lmCoord.x, 3.0);
      blockLight += vec3(1.0, 0.9, 0.8) * 0.4 * pow(lmCoord.x, 6.0);
      blockLight += vec3(1.0, 0.9, 0.8) * 0.6 * pow(lmCoord.x, 8.0);
      blockLight += vec3(1.0, 0.2, 0.0) * 8.0 * pow(lmCoord.x, 24.0);

outColor = outColor * (sunLight + skyLight + blockLight);