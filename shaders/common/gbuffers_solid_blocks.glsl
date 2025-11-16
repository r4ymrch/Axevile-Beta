#include "/lib/settings.glsl"

#ifdef FSH

varying vec2 lmCoord, texCoord;
varying vec4 tintColor;
varying vec4 normal;

uniform sampler2D texture;

#include "/lib/utils.glsl"
#include "/lib/encode.glsl"

void main() {
	vec4 color = texture2D(texture, texCoord);

	// Reduce vanilla ao
	vec4 inColor = tintColor;
	vec3 nColor = normalize(tintColor.rgb);

	if (nColor.g > nColor.b && inColor.a == 1.0) {
  	color.rgb *= mix(nColor, inColor.rgb, 0.5);
	} else {
  	color.rgb *= (inColor.a == 0.0) ? inColor.rgb : sqrt(inColor.rgb);
	}

	// srgb to linear
	color.rgb = SRGBToLinear(color.rgb);

	/* DRAWBUFFERS:012 */
	gl_FragData[0] = color; // gcolor
	gl_FragData[1] = vec4(lmCoord, 0.0, 1.0); // lightmap
	gl_FragData[2] = vec4(EncodeNormal(normal.rgb), normal.a, 1.0); // gnormal
}

#endif

#ifdef VSH

attribute vec4 mc_Entity;

varying vec2 lmCoord, texCoord;
varying vec4 tintColor;
varying vec4 normal;

uniform float timeAngle;
uniform mat4 gbufferModelView;

#include "/lib/utils.glsl"

void main() {
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	lmCoord = lmCoord  / (30.0 / 32.0) - (1.0 / 32.0);
	tintColor = gl_Color;

	vec3 sunVector, upVector, lightVector;
	#include "/lib/src/sunVector.glsl"

	normal.rgb = normalize(gl_NormalMatrix * gl_Normal);
	normal.a = clamp(2.2 * dot(normal.rgb, lightVector), 0.0, 1.0);
	if (mc_Entity.x == 100 || mc_Entity.x == 105) normal.a = 1.0;

	gl_Position = ftransform();
}

#endif