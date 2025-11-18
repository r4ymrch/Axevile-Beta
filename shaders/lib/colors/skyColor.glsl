/*
====================================================
- Axevile shaders v1.0.0 developed and maintaned by r4ymrch.
- See README.md for more details about this shaders.
- Last modified : 11/18/2025.
====================================================
*/

vec3 skyColor = mix(vec3(0.3, 0.5, 1.0) * 0.5, vec3(0.3, 0.5, 1.0), dayTime);
vec3 fogColor = mix(vec3(1.0, 0.6, 0.3) * 1.5, vec3(0.9, 0.95, 1.0), dayTime);
vec3 nightColor = vec3(0.2, 0.25, 0.35);