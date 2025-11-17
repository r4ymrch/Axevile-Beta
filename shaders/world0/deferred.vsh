/*
- Axevile v1.0.0 - deferred program.
- See README.md for more details.
*/

#version 120

varying vec2 texCoord;

void main()
{
  texCoord = gl_MultiTexCoord0.xy;
  gl_Position = ftransform();
}