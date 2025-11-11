#include "/lib/config.glsl"

#ifdef FSH

// Main program
void main() {
  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(0.0);
}

#endif // FSH

#ifdef VSH

// Main program
void main() {
  gl_Position = ftransform();
}

#endif // VSH