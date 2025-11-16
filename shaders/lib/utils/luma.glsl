/*
- Axevile v1.0.0 - luma functions.
- See README.md for more details.
*/

float GetLuminance(vec3 x) {
  return dot(x, vec3(0.2125, 0.7154, 0.0721));
}

float GetColorAverage(vec3 x) {
  return (x.r + x.g + x.b) / 3.0;
}