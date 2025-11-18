/*
====================================================
- Axevile shaders v1.0.0 developed and maintaned by r4ymrch.
- See README.md for more details about this shaders.
- Last modified : 11/18/2025.
====================================================
*/

vec3 ToViewSpace(vec3 fragPos) {
	vec4 viewPos = gbufferProjectionInverse * (vec4(fragPos, 1.0) * 2.0 - 1.0);
	return viewPos.xyz / viewPos.w;
}

vec3 ToScreenSpace(vec3 fragPos) {
	vec4 screenPos = gbufferProjection * vec4(fragPos, 1.0);
	vec3 ndc = screenPos.xyz / screenPos.w;
	return ndc * 0.5 + 0.5;
}

vec3 ToWorldSpace(vec3 fragPos) {
	return mat3(gbufferModelViewInverse) * fragPos + gbufferModelViewInverse[3].xyz;
}

vec3 ToShadowSpace(vec3 fragPos) {
	vec3 shadowPos = mat3(shadowModelView) * fragPos + shadowModelView[3].xyz;
	
  vec3 diagonal3 = vec3(
    shadowProjection[0].x, 
    shadowProjection[1].y, 
    shadowProjection[2].z
  );
  
  return diagonal3 * shadowPos + shadowProjection[3].xyz;
}