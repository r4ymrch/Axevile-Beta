/*
====================================================
- Axevile shaders v1.0.0 developed and maintaned by r4ymrch.
- See README.md for more details about this shaders.
- Last modified : 11/18/2025.
====================================================
*/

float Luminance(vec3 x) {
  return dot(x, vec3(0.2125, 0.7154, 0.0721));
}