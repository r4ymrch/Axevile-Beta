vec3 sRGBToLinear(vec3 srgb) {
  return pow(srgb, vec3(2.2));
}