/*
- Axevile v1.0.0 - deferred program.
- See README.md for more details.
*/

#version 120

varying vec2 texCoord;

uniform sampler2D texture;

void main() {
	gl_FragData[0] = texture2D(texture, texCoord);
}