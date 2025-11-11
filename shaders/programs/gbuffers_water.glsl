#include "/lib/config.glsl"

#ifdef FSH

// Varyings

// Uniforms

// Common functions
#include "/lib/utility.glsl"

// Main program
void main() {
  vec4 albedo = vec4(0.0);

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = albedo;
}

#endif // FSH

#ifdef VSH

// Varyings

// Main program
void main() {
  gl_Position = ftransform();
}

#endif // VSH