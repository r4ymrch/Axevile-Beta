#include "/lib/config.glsl"

#ifdef FSH

// Varyings
varying vec2 texCoord;

// Uniforms
uniform sampler2D texture;

// Main program
void main() {
  gl_FragData[0] = texture2D(texture, texCoord);
}

#endif // FSH

#ifdef VSH

// Varyings
varying vec2 texCoord;

// Uniforms
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform mat4 shadowModelViewInverse;
uniform mat4 shadowProjectionInverse;

// Main program
void main() {
  texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  
  vec4 position = shadowModelViewInverse * shadowProjectionInverse * ftransform();
	gl_Position = shadowProjection * shadowModelView * position;

	float distb = sqrt(dot(gl_Position.xy, gl_Position.xy));
  float distortFactor = distb * SHADOW_MAP_BIAS + (1.0 - SHADOW_MAP_BIAS);

	gl_Position.xy /= distortFactor;
	gl_Position.z *= 0.2;
}

#endif // VSH