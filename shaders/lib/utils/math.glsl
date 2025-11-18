/*
====================================================
- Axevile shaders v1.0.0 developed and maintaned by r4ymrch.
- See README.md for more details about this shaders.
- Last modified : 11/18/2025.
====================================================
*/

float pow2(float x) { return x * x; }
vec2 pow2(vec2 x) {   return x * x; }
vec3 pow2(vec3 x) {   return x * x; }
vec4 pow2(vec4 x) {   return x * x; }

float pow3(float x) { return x * x * x; }
vec2 pow3(vec2 x) {   return x * x * x; }
vec3 pow3(vec3 x) {   return x * x * x; }
vec4 pow3(vec4 x) {   return x * x * x; }

float pow4(float x) { return pow2(pow2(x)); }
vec2 pow4(vec2 x) {   return pow2(pow2(x)); }
vec3 pow4(vec3 x) {   return pow2(pow2(x)); }
vec4 pow4(vec4 x) {   return pow2(pow2(x)); }

float pow5(float x) { return pow2(pow2(x)) * x; }
vec2 pow5(vec2 x) {   return pow2(pow2(x)) * x; }
vec3 pow5(vec3 x) {   return pow2(pow2(x)) * x; }
vec4 pow5(vec4 x) {   return pow2(pow2(x)) * x; }

float pow6(float x) { return pow3(pow2(x)); }
vec2 pow6(vec2 x) {   return pow3(pow2(x)); }
vec3 pow6(vec3 x) {   return pow3(pow2(x)); }
vec4 pow6(vec4 x) {   return pow3(pow2(x)); }

float pow7(float x) { return pow3(pow2(x)) * x; }
vec2 pow7(vec2 x) {   return pow3(pow2(x)) * x; }
vec3 pow7(vec3 x) {   return pow3(pow2(x)) * x; }
vec4 pow7(vec4 x) {   return pow3(pow2(x)) * x; }

float pow8(float x) { return pow4(pow2(x)); }
vec2 pow8(vec2 x) {   return pow4(pow2(x)); }
vec3 pow8(vec3 x) {   return pow4(pow2(x)); }
vec4 pow8(vec4 x) {   return pow4(pow2(x)); }

float pow9(float x) { return pow3(pow3(x)); }
vec2 pow9(vec2 x) {   return pow3(pow3(x)); }
vec3 pow9(vec3 x) {   return pow3(pow3(x)); }
vec4 pow9(vec4 x) {   return pow3(pow3(x)); }

float pow10(float x) { return pow5(pow2(x)); }
vec2 pow10(vec2 x) {   return pow5(pow2(x)); }
vec3 pow10(vec3 x) {   return pow5(pow2(x)); }
vec4 pow10(vec4 x) {   return pow5(pow2(x)); }

float fogify(float x, float w) {
	return w / (x * x + w);
}

float clamp01(float x) {
  return min(max(x, 0.0), 1.0);
}

vec2 clamp01(vec2 x) {
  return min(max(x, vec2(0.0)), vec2(1.0));
}

vec3 clamp01(vec3 x) {
  return min(max(x, vec3(0.0)), vec3(1.0));
}

vec4 clamp01(vec4 x) {
  return min(max(x, vec4(0.0)), vec4(1.0));
}

mat2 rotate2D(float x) {
  return mat2(cos(x), sin(x), -sin(x), cos(x));
}