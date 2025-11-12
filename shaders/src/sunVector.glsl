float sunAngle = fract(timeAngle - 0.25);
sunAngle = (sunAngle + (cos(sunAngle * 3.14159265358979) * -0.5 + 0.5 - sunAngle) / 3.0) * 6.28318530717959;

sunVec = (gbufferModelView * vec4(vec3(-sin(sunAngle), cos(sunAngle), 0.0) * 2000.0, 1.0)).xyz;
sunVec = normalize(sunVec);