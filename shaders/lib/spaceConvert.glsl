vec3 toViewSpace(vec3 screenPos) {
	vec4 position = vec4(screenPos, 1.0) * 2.0 - 1.0;
	vec4 viewSpace = gbufferProjectionInverse * position;
	return viewSpace.xyz / viewSpace.w;
}

vec3 toScreenSpace(vec3 viewSpace) {
	vec4 position = gbufferProjection * vec4(viewSpace, 1.0);
	vec3 ndc = position.xyz / position.w;
	return ndc * 0.5 + 0.5;
}

vec3 toWorldSpace(vec3 viewSpace) {
	return mat3(gbufferModelViewInverse) * viewSpace + gbufferModelViewInverse[3].xyz;
}