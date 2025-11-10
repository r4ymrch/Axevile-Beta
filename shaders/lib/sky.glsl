const vec3 day_sky_color = vec3(
  CFG_DAY_SKY_COLOR_CR, 
  CFG_DAY_SKY_COLOR_CG, 
  CFG_DAY_SKY_COLOR_CB
) * CFG_DAY_SKY_COLOR_CA;

const vec3 sun_sky_color = vec3(
  CFG_SUN_SKY_COLOR_CR, 
  CFG_SUN_SKY_COLOR_CG, 
  CFG_SUN_SKY_COLOR_CB
) * CFG_SUN_SKY_COLOR_CA;

const vec3 night_sky_color = vec3(
  CFG_NIG_SKY_COLOR_CR, 
  CFG_NIG_SKY_COLOR_CG, 
  CFG_NIG_SKY_COLOR_CB
) * CFG_NIG_SKY_COLOR_CA;

const vec3 day_fog_color = vec3(
  CFG_DAY_FOG_COLOR_CR, 
  CFG_DAY_FOG_COLOR_CG, 
  CFG_DAY_FOG_COLOR_CB
) * CFG_DAY_FOG_COLOR_CA;

const vec3 sun_fog_color = vec3(
  CFG_SUN_FOG_COLOR_CR, 
  CFG_SUN_FOG_COLOR_CG, 
  CFG_SUN_FOG_COLOR_CB
) * CFG_SUN_FOG_COLOR_CA;

const vec3 night_fog_color = vec3(
  CFG_NIG_FOG_COLOR_CR, 
  CFG_NIG_FOG_COLOR_CG, 
  CFG_NIG_FOG_COLOR_CB
) * CFG_NIG_FOG_COLOR_CA;

float Hash13(vec3 p) {
  p = fract(p * 0.1031);
  p += dot(p, p.zyx + 31.32);
  return fract((p.x + p.y) * p.z);
}

float ZenithDensity(float posY, float offset, float x) {
  float height = posY + offset;
  return x / (height * height + x);
}

float GroundDensity(float posY, float offset, float density) {
  float height = posY + offset;
  return clamp(exp(-height * density), 0.0, 1.0);
}

float PhaseMie(float mu, float g) {
  float mu2 = mu * mu;
	float gg = g * g;
  return 3.0 / (8.0 * 3.14) * ((1.0 - gg) * (mu2 + 1.0)) / (pow(1.0 + gg - 2.0 * mu * g, 1.5) * (2.0 + gg));
}

vec3 ColorDesaturation(vec3 color, float x) {
  float luma = GetLuminance(color);
	return mix(color, vec3(luma), x);
}

vec3 CalcBaseSky(vec3 worldPos) {
  vec3 worldSunVec = mat3(gbufferModelViewInverse) * sunVec;

  float PdotS = dot(worldPos, worldSunVec);
  float PdotM = dot(worldPos, -worldSunVec);

  float skyMixer = mix(PhaseMie(PdotS, 0.2) * 4.0, PhaseMie(PdotS, 0.1) * 12.0, dayMixer);
        skyMixer = mix(skyMixer, 0.0, nightMixer);

  float dayZenith = ZenithDensity(worldPos.y, ZENITH_OFFSETS, ZENITH_DENSITY * 0.1);
  float nightZenith = ZenithDensity(worldPos.y, 0.0, 0.08);
	
  vec3 sunSkyColor = mix(sun_sky_color, day_sky_color, dayMixer);
  vec3 sunFogColor = mix(sun_fog_color, day_fog_color, dayMixer);

	vec3  daySky = mix(vec3(0.0), sunSkyColor, clamp(1.0 - worldPos.y * 0.5, 0.0, 1.0));
        daySky = mix(daySky, sunSkyColor, rainStrength);
        daySky = mix(daySky, sunFogColor, dayZenith);

  vec3  nightSky = mix(vec3(0.0), night_sky_color, clamp(1.0 - worldPos.y * 0.125, 0.0, 1.0));
        nightSky = mix(nightSky, night_sky_color, rainStrength);
        nightSky = mix(nightSky, night_fog_color, nightZenith);
  
  vec3 totalSky = mix(nightSky, daySky, skyMixer);

  float ground;
  float groundBase = GroundDensity(worldPos.y, SKY_GROUND_OFFSETS * 0.1, SKY_GROUND_DENSITY);
  
  #ifdef SKY_GROUND
    ground = GroundDensity(worldPos.y, SKY_GROUND_OFFSETS * 0.1, SKY_GROUND_DENSITY);
    ground *= mix(SKY_GROUND_INTENSITY * 0.4, 0.3, nightMixer);
    ground *= groundBase;
    
    float bottomDayZenith = ZenithDensity(-worldPos.y, ZENITH_OFFSETS, ZENITH_DENSITY * 0.1);
    float bottomNightZenith = ZenithDensity(-worldPos.y, 0.0, 0.08);
    
	  vec3  bottomDaySky = mix(vec3(0.0), sunSkyColor, clamp(-worldPos.y * 0.5, 0.0, 1.0));
          bottomDaySky = mix(bottomDaySky, sunSkyColor, rainStrength);
          bottomDaySky = mix(bottomDaySky, sunFogColor, bottomDayZenith);
    
    vec3  bottomNightSky = mix(vec3(0.0), night_sky_color, clamp(-worldPos.y * 0.125, 0.0, 1.0));
          bottomNightSky = mix(bottomNightSky, night_sky_color, rainStrength);
          bottomNightSky = mix(bottomNightSky, night_fog_color, bottomNightZenith);
    
    vec3 bottomSky = mix(bottomNightSky, bottomDaySky, skyMixer);

    vec3 shadowColor = ColorDesaturation(sunSkyColor, 0.75) * SKY_GROUND_BRIGHTNESS;
    
    totalSky = mix(totalSky, shadowColor, groundBase);
    totalSky = mix(totalSky, bottomSky, ground);
  #else
    ground = clamp(exp(-(worldPos.y + 0.08) * 16.0), 0.0, 1.0);
    totalSky = mix(totalSky, mix(night_fog_color, sunFogColor, skyMixer), ground);
  #endif

  return totalSky;
}

vec3 DrawSunMoon(vec3 worldPos, bool isSky) {
  vec3 worldSunVec = mat3(gbufferModelViewInverse) * sunVec;

  float PdotS = dot(worldPos, worldSunVec);
  float PdotM = dot(worldPos, -worldSunVec);
  float PdistS = distance(worldPos, worldSunVec);
  float groundBase = GroundDensity(worldPos.y, SKY_GROUND_OFFSETS * 0.1, SKY_GROUND_DENSITY);

  vec3 sunFogColor = mix(sun_fog_color, day_fog_color, dayMixer);

  vec3  sun = sunFogColor * 3.0 * smoothstep(0.035, 0.025, PdistS);
        sun *= (1.0 - groundBase) * float(isSky) * (1.0 - rainStrength);

  vec3  miePhaseSun = sunFogColor * PhaseMie(PdotS, MIE_PHASE_G) * MIE_PHASE_STRENGTH * 0.075;
        miePhaseSun *= (1.0 - nightMixer) * float(isSky);

  vec3  miePhaseSun2 = sunFogColor * PhaseMie(PdotS, MIE_PHASE_G2) * MIE_PHASE_STRENGTH2;
        miePhaseSun2 *= (1.0 - nightMixer);

  vec3  miePhaseMoon = night_fog_color * PhaseMie(PdotM, 0.65) * 0.25;
        miePhaseMoon *= nightMixer * (1.0 - groundBase);
  
  vec3  miePhaseMoon2 = night_fog_color * PhaseMie(PdotM, 0.95) * 0.035 * nightMixer;
        miePhaseMoon2 *= (1.0 - groundBase) * float(isSky);
  
  vec3  miePhase = miePhaseSun + miePhaseMoon;
  vec3  miePhase2 = miePhaseSun2 + miePhaseMoon2;
        
  miePhase += miePhase2;
  miePhase *= (1.0 - rainStrength);
  
  return sun + miePhase;
}

vec3 DrawStars(vec3 worldPos) {
  vec3 worldSunVec = mat3(gbufferModelViewInverse) * sunVec;

  float PdotS = dot(worldPos, worldSunVec);
  float PdotM = dot(worldPos, -worldSunVec);

  float skyMixer = mix(PhaseMie(PdotS, 0.2) * 4.0, PhaseMie(PdotS, 0.1) * 12.0, dayMixer);
        skyMixer = mix(skyMixer, 0.0, nightMixer);

  float groundBase = GroundDensity(worldPos.y, SKY_GROUND_OFFSETS * 0.1, SKY_GROUND_DENSITY);
  float stars = Hash13(floor((abs(worldPos) + 16.0) * 256.0));
        stars = smoothstep(0.9985, 1.0, stars);
        stars *= 1.0 - max(groundBase, skyMixer);

  return night_fog_color * stars * (1.0 - rainStrength);
}

vec3 CalcSky(vec3 worldPos, bool isSky) {
  vec3 baseSky = CalcBaseSky(worldPos);
  vec3 sunMoon = DrawSunMoon(worldPos, isSky);
  vec3 stars = DrawStars(worldPos);
  
  vec3 totalSky = baseSky + stars + sunMoon;
  vec3 rainColor = ColorDesaturation(totalSky, rainStrength) * vec3(0.65, 0.8, 1.0);
  
  return mix(totalSky, rainColor, rainStrength);
}
