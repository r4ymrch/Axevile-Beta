vec3 AxevileTonemap(vec3 x) {
	return x / (0.9813 * x + 0.1511);
}

vec3 Final(vec3 color) {
	color *= 1.3;
  color = AxevileTonemap(color);
	return color;
}