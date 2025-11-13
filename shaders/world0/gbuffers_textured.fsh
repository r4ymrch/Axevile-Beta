#version 120

varying vec2 lmcoord, texcoord;
varying vec3 viewSpace, worldSpace;
varying vec4 normal;
varying vec3 sunVector, lightVector, upVector;
varying vec4 glcolor;

uniform sampler2D lightmap;
uniform sampler2D texture;

uniform float far;
uniform float rainStrength;
uniform float dayTime, nightTime;

uniform mat4 gbufferModelView;

#include "/lib/utils.glsl"
#include "/lib/colors.glsl"
#include "/lib/sky.glsl"

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	
	// srgb to linear
	color.rgb = SRGBToLinear(color.rgb);

	// ligting
	vec3 sunLight = mix(fogColor, nightColor * 0.25, nightTime);
  sunLight *= normal.a * pow(lmcoord.y, 6.0);
  sunLight *= (1.0 - rainStrength);

  float noShadowTime = 1.0 - max(
    clamp(dot(sunVector, upVector) * 24.0, 0.0, 1.0), 
    clamp(dot(-sunVector, upVector) * 6.0, 0.0, 1.0)
  );

  sunLight = mix(sunLight, vec3(0.0), noShadowTime);

	vec3 skyLight = mix(skyColor, vec3(GetLuminance(skyColor)), 0.5);
  skyLight = mix(skyLight, nightColor * 0.25, nightTime);
  skyLight = mix(skyLight * 1.3, skyLight * 1.35, rainStrength);
  skyLight *= pow(lmcoord.y, 2.0);

  vec3 blockLight = vec3(1.0, 0.9, 0.8) * 0.2 * lmcoord.x * lmcoord.y;
  blockLight += vec3(1.0, 0.9, 0.8) * 0.4 * pow(lmcoord.x, 3.0);
  blockLight += vec3(1.0, 0.9, 0.8) * 0.4 * pow(lmcoord.x, 6.0);
  blockLight += vec3(1.0, 0.9, 0.8) * 0.6 * pow(lmcoord.x, 8.0);
  blockLight += vec3(1.0, 0.35, 0.0) * 8.0 * pow(lmcoord.x, 24.0);

  color.rgb = color.rgb * (sunLight + skyLight + blockLight);
	
	// fog
	float farDist = far;
	float fogDist = clamp(length(worldSpace) / farDist, 0.0, 1.0);
	fogDist = pow(fogDist, 5.0);

	float mistFog = clamp(length(worldSpace) * 0.0256, 0.0, 1.0) * 0.1;

	vec3 zenithColor = mix(nightColor, skyColor, dayTime);
	vec3 skyFog = CalcSky(normalize(viewSpace)).rgb;

	// color.rgb = mix(color.rgb, SRGBToLinear(zenithColor), mistFog);
	// color.rgb = mix(color.rgb, SRGBToLinear(skyFog), fogDist);

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}