/*
- Axevile v1.0.0 - source code.
- See README.md for more details.
*/

float fogFactor = GetFogFactor(viewPos, z);

vec3  skyFog = CalcSky(normalize(viewPos), z == 1.0).rgb;
      skyFog = pow(skyFog, vec3(2.2));

outColor = mix(outColor, skyFog, fogFactor);