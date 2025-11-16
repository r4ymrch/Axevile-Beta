#include "/lib/settings.glsl"

#ifdef FSH

varying vec2 texCoord;
varying vec3 sunVector, lightVector, upVector;

uniform sampler2D noisetex;
uniform sampler2D depthtex0;

uniform sampler2D colortex0; // gcolor
uniform sampler2D colortex1; // lightmap
uniform sampler2D colortex2; // gnormal

uniform float rainStrength;
uniform float dayTime, nightTime;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

#include "/lib/utils.glsl"
#include "/lib/encode.glsl"
#include "/lib/spaceConvert.glsl"
#include "/lib/colors.glsl"
#include "/lib/shadows.glsl"

void DiffuseLighting(inout vec3 color, in vec3 viewPos, in vec3 worldPos, in vec3 normal, in vec2 lmCoord, in float NdotL) {
	float noShadowTime = 1.0 - max(
    clamp(dot(sunVector, upVector) * 24.0, 0.0, 1.0), 
    clamp(dot(-sunVector, upVector) * 6.0, 0.0, 1.0)
	);

	float PdistS = distance(normalize(viewPos), sunVector);
  float PdistM = distance(normalize(viewPos), -sunVector);
    
  float subsurfaceSun = exp(-length(PdistS) * 4.0) * 6.0 * (1.0 - nightTime);
  float subsurfaceMoon = exp(-length(PdistM) * 4.0) * 6.0 * nightTime;
  float subsurface = subsurfaceSun + subsurfaceMoon;

	vec3 sunLight = mix(vec3(1.0, 0.5, 0.0), fogColor, dayTime);
	sunLight = mix(sunLight, nightColor * 0.25, nightTime);
	sunLight = mix(sunLight, sunLight * 2.0, subsurface);
	
	sunLight *= GetShadows(worldPos, normal, NdotL);

	sunLight = mix(sunLight, vec3(0.0), noShadowTime);
	sunLight *= (1.0 - rainStrength);

	vec3 zenithColor = mix(vec3(GetLuminance(skyColor)), skyColor, 0.85) * 0.75;
	vec3 skyLight = mix(nightColor, zenithColor, dayTime);
	skyLight = mix(skyLight, nightColor * 0.5, nightTime);
	skyLight = mix(skyLight, nightColor * 0.75, noShadowTime);
		
	skyLight *= 0.75;
	skyLight *= pow(lmCoord.y, 3.0);

	vec3 blockLight = vec3(1.0, 0.9, 0.8) * 0.2 * lmCoord.x * lmCoord.y;
  blockLight += vec3(1.0, 0.9, 0.8) * 0.4 * pow(lmCoord.x, 3.0);
  blockLight += vec3(1.0, 0.9, 0.8) * 0.4 * pow(lmCoord.x, 6.0);
  blockLight += vec3(1.0, 0.9, 0.8) * 0.6 * pow(lmCoord.x, 8.0);
  blockLight += vec3(1.0, 0.2, 0.0) * 8.0 * pow(lmCoord.x, 24.0);

	color = color * (sunLight + skyLight + blockLight);
}

void main() {
	vec3 color = texture2D(colortex0, texCoord).rgb;
	vec3 normal = DecodeNormal(texture2D(colortex2, texCoord).rg);
	normal = normalize(normal);

	float z = texture2D(depthtex0, texCoord).r;
	bool land = z < 1.0;

	vec2 lmCoord = texture2D(colortex1, texCoord).rg;
	vec3 viewPos = toViewSpace(vec3(texCoord, z));
	vec3 worldPos = toWorldSpace(viewPos);

	if (land) {
		float NdotL = texture2D(colortex2, texCoord).b;
		DiffuseLighting(color, viewPos, worldPos, normal, lmCoord, NdotL);
	}

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); // gcolor
}

#endif

#ifdef VSH

varying vec2 texCoord;
varying vec3 sunVector, lightVector, upVector;

uniform float timeAngle;
uniform mat4 gbufferModelView;

void main() {
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	#include "/lib/src/sunVector.glsl"
	gl_Position = ftransform();
}

#endif