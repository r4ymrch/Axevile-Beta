float Hash13(vec3 p) {
  p = abs(p) + 16.0;
  p = floor(p * 256.0);
  p = fract(p * 0.1031);
  p += dot(p, p.zyx + 31.32);
  return fract((p.x + p.y) * p.z);
}
