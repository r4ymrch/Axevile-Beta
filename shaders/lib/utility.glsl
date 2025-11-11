#define Rotate2D(x) mat2(cos(x), sin(x), -sin(x), cos(x))
#define Diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define ProjMAD(m, v) (Diagonal3(m) * (v) + (m)[3].xyz)

vec3 SRGBToLinear(vec3 srgb) {
  return pow(srgb, vec3(2.2));
}

vec3 LinearToSRGB(vec3 linear) {
  return pow(linear, vec3(1.0 / 2.2));
}

float GetLuminance(vec3 x) {
  return dot(x, vec3(0.2125, 0.7154, 0.0721));
}

vec3 Mat4x4Vec3_To_Vec3(mat4 m, vec3 v) {
  vec4 v4 = vec4(v, 1.0);
  vec4 result = m * v4;
  return result.xyz / result.w;
}
