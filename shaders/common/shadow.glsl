#include "/lib/settings.glsl"

#ifdef FSH

varying vec2 texCoord;

uniform sampler2D texture;

void main() {
	gl_FragData[0] = texture2D(texture, texCoord);
}

#endif

#ifdef VSH

varying vec2 texCoord;

void main() {
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	gl_Position = ftransform();

	float dist = sqrt(dot(gl_Position.xy, gl_Position.xy));
  float distortFactor = dist * SHADOW_MAP_BIAS + (1.0 - SHADOW_MAP_BIAS);

  gl_Position.xy /= distortFactor;
  gl_Position.z *= 0.2;
}

#endif