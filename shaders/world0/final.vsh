#version 120

/*
====================================================
- Axevile shaders v1.0.0 developed and maintaned by r4ymrch.
- See README.md for more details about this shaders.
- Last modified : 11/18/2025.
====================================================
*/

// Configurations
#include "/lib/settings.glsl"

// Varyings
varying vec2 texCoord;

// Main program
void main()
{
  texCoord = gl_MultiTexCoord0.xy;
  gl_Position = ftransform();
}