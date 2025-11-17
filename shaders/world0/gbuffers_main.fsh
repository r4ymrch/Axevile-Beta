/*
- Axevile v1.0.0 - main program.
- See README.md for more details.
*/

#include "/lib/settings.glsl"

varying vec3 viewPos;
varying vec3 sunVector, lightVector, upVector;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

#if defined(GBUFFERS_SOLID) || defined(GBUFFERS_TRANSLUCENT)
  varying vec2 texCoord, lmCoord;
  varying vec3 tangent, binormal;
  varying vec3 viewVector;
  varying vec4 normal;
  varying vec4 tintColor;
#endif

#if defined(GBUFFERS_SOLID) || defined(GBUFFERS_TRANSLUCENT)
  uniform sampler2D texture;
  uniform sampler2D gaux1;
  uniform sampler2D depthtex1;
#endif

uniform float rainStrength;
uniform float dayTime, nightTime;
uniform float viewWidth, viewHeight;

// Common functions.
const float ambientOcclusionLevel = 0.5;

#include "/lib/utils/math.glsl"
#include "/lib/utils/luma.glsl"
#include "/lib/utils/encode.glsl"
#include "/lib/utils/spaceConvert.glsl"
#include "/lib/colors/skyColor.glsl"
#include "/lib/atmospherics/sky.glsl"

#if defined(GBUFFERS_TRANSLUCENT)
  uniform float frameTimeCounter;
  uniform vec3 cameraPosition;

// https://github.com/robobo1221/robobo1221Shaders/
    float calcwave(vec2 pos, float waveLength, float magnitude, vec2 waveDir, float waveAmp, float waveStrength){
        float k = 6.28 / waveLength;
        float x = sqrt(19.6 * k) * magnitude - (k * dot(waveDir, pos));
        return waveAmp * pow(sin(x) * 0.5 + 0.5, waveStrength);
    }

    float GetWaterHeightMap(vec3 pos){
        float waveLength = 10.0;
        float magnitude = frameTimeCounter * 0.3;
        float waveAmp = 0.3;
        float waveStrength = 0.6;
        vec2 waveDir = vec2(1.0, 0.5);
        float sum = 0.0;
        for(int i = 0; i < 10; i++){
            sum += calcwave(pos.xz, waveLength, magnitude, waveDir, waveAmp, waveStrength);
            waveLength *= 0.7;
            waveAmp *= 0.62;
            waveStrength *= 1.03;
            waveDir *= mat2(cos(0.5), -sin(0.5), sin(0.5), cos(0.5));
            magnitude *= 1.1;
        }
        return sum;
    }

vec3 GetParallaxWaves(vec3 worldPos, vec3 viewVector) {
    vec3 parallaxPos = worldPos * 1.5;
    
    for(int i = 0; i < 4; i++) {
        float height = -1.5 * GetWaterHeightMap(parallaxPos);
        parallaxPos.xz += height * viewVector.xy / length(viewPos);
    }

    return parallaxPos;
}

vec3 GetWaterNormal(vec3 worldPos, vec3 viewVector) {
    vec3  waterPos = worldPos + cameraPosition;
    waterPos = GetParallaxWaves(waterPos, viewVector);

    float fresnel = pow(clamp(1.0 + dot(normalize(normal.xyz), normalize(viewPos)), 0.0, 1.0), 4.0);
    float offset = mix(0.3, 0.0, fresnel);

    float h0 = GetWaterHeightMap(waterPos);
    float h1 = GetWaterHeightMap(waterPos + vec3(offset, 0.0, 0.0));
    float h2 = GetWaterHeightMap(waterPos + vec3(0.0, 0.0, offset));

    vec3  wNormal = normalize(vec3(h0 - h1, h0 - h2, 1.0)) * 0.5 + 0.5;
		      wNormal = wNormal * 2.0 - 1.0;
    
    return wNormal;
}

float ggx(float ndl, float ndv, float ndh, float f0) {
	float rs = f0 * f0 * f0 * f0;
	float d = (ndh * rs - ndh) * ndh + 1.0;
	float nd = rs / (3.14 * d * d);
	float k =(f0 * f0) * 0.5;
	float v = ndv * (1.0 - k) + k;
	float l = ndl * (1.0 - k) + k;
	return max(0.0, nd * (0.25 / (v * l)));
}

float GetUnderwaterFogFactor(vec3 viewPos) {
	float dist = length(viewPos) * 0.02;
	float fogFactor = exp(-1.5 * (1.0 - dist));
	fogFactor = clamp(fogFactor, 0.0, 1.0);

	return fogFactor;
}

#endif

void main() 
{
  vec4 outColor = CalcSky(normalize(viewPos), true);

  #if defined(GBUFFERS_SOLID)
    vec4 albedo = texture2D(texture, texCoord) * tintColor;
    outColor = albedo;
  #endif

  #if defined(GBUFFERS_TRANSLUCENT)
  mat3 tbnMatrix = mat3(
    tangent.x, binormal.x, normal.x, 
    tangent.y, binormal.y, normal.y, 
    tangent.z, binormal.z, normal.z
  );

    vec3 normalMap = GetWaterNormal(ToWorldSpace(viewPos), viewVector);
	  vec3 newNormal = clamp(normalize(normalMap * tbnMatrix), vec3(-1.0), vec3(1.0));

    vec3 screenPos = ToScreenSpace(viewPos);

    float waterZ = texture2D(depthtex1, screenPos.xy).r;
    vec3 viewPos1 = ToViewSpace(vec3(screenPos.xy, waterZ));
  vec3 raPos = refract(normalize(viewPos), newNormal - normal.xyz, 0.5) * distance(viewPos, viewPos1);
	raPos = ToScreenSpace(raPos + viewPos);


  float rgbOffset = 0.005;
  vec3 watercolor1   = vec3(0.0);
	watercolor1.r = texture2D(gaux1, raPos.st + rgbOffset).r;
	watercolor1.g = texture2D(gaux1, raPos.st).g;
	watercolor1.b = texture2D(gaux1, raPos.st - rgbOffset).b;

    vec4 waterColor = vec4(watercolor1, 1.0);

    vec3  uPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), waterZ);
          uPos = ToViewSpace(uPos);
    vec3 uVec = viewPos - uPos;
  
    float UNdotUP = abs(dot(normalize(uVec), normal.xyz));
    float underwaterDepth = 1.0 - clamp(length(uVec) * UNdotUP * 0.1, 0.0, 1.0);

    float absorbDensity = pow(max(underwaterDepth, 0.0), 1.5); 
    vec3 waterAbsorb = mix(vec3(0.0, 1.0, 1.0) * 1.5, vec3(1.0), absorbDensity);
    waterColor.rgb *= waterAbsorb;

    float distanceFog = GetUnderwaterFogFactor(uPos);
    vec3  waterFogColor = vec3(0.2, 0.8, 1.0) * mix(0.1, 0.25, dayTime);
	        waterFogColor = mix(waterFogColor, vec3(GetLuminance(waterFogColor)) * vec3(0.65, 0.8, 1.0), rainStrength);
	
    waterColor = mix(vec4(waterFogColor, 1.0), waterColor, underwaterDepth);
    waterColor = mix(waterColor, vec4(waterFogColor, 1.0), distanceFog);

    vec3 reflectedPos = reflect(normalize(viewPos), newNormal);
    vec4 reflection = vec4(CalcSky(reflectedPos, true).rgb, 0.0);

    vec3 viewDir = normalize(-viewPos);
	float NdotV = max(0.001, dot(newNormal, viewDir));
	float NdotL = max(0.001, dot(newNormal, lightVector));
	float NdotH = max(0.001, dot(newNormal, normalize(viewDir + lightVector)));
	
	float f0 = 0.1;
	float fresnel = f0 + (1.0 - f0) * pow(1.0 - NdotV, 5.0);

	waterColor = mix(waterColor, vec4(reflection.rgb, 1.0), fresnel);

  vec3 lightColor = mix(fogColor, nightColor, nightTime);
	waterColor += vec4(lightColor * 3.0, 1.0) * ggx(NdotL, NdotV, NdotH, 0.05) * (1.0 - reflection.a) * (1.0 - rainStrength);
    
    outColor = waterColor;
  #endif

  // Apply gamma correction
  outColor.rgb = pow(outColor.rgb, vec3(2.2));

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = outColor;

  #if defined(GBUFFERS_SOLID) || defined(GBUFFERS_TRANSLUCENT)
    /* DRAWBUFFERS:012 */
    gl_FragData[1] = vec4(lmCoord, 0.0, 1.0);
    gl_FragData[2] = vec4(EncodeNormal(normal.xyz), normal.w, 1.0);
  #endif
}