/*
- Axevile v1.0.0 - space conversion functions.
- See README.md for more details.
*/

vec3 ToViewSpace(vec3 screenSpace) {
	vec4 position = gbufferProjectionInverse * (vec4(screenSpace, 1.0) * 2.0 - 1.0);
	return position.xyz / position.w;
}

vec3 ToScreenSpace(vec3 viewSpace) {
	vec4 position = gbufferProjection * vec4(viewSpace, 1.0);
	vec3 ndc = position.xyz / position.w;
	return ndc * 0.5 + 0.5;
}

vec3 ToWorldSpace(vec3 viewSpace) {
	return mat3(gbufferModelViewInverse) * viewSpace + gbufferModelViewInverse[3].xyz;
}

vec3 ToShadowSpace(vec3 worldSpace) {
	vec3 pos = mat3(shadowModelView) * worldSpace + shadowModelView[3].xyz;
	return ProjMAD(shadowProjection, pos);
}