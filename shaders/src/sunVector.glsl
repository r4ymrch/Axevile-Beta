float sunAngle = fract(timeAngle - 0.25);
sunAngle = (sunAngle + (cos(sunAngle * 3.14159265358979) * -0.5 + 0.5 - sunAngle) / 3.0) * 6.28318530717959;

sunVec = vec3(-sin(sunAngle), cos(sunAngle), 0.0) * 2000.0;
sunVec.yz *= Rotate2D(radians(sunPathRotation));
sunVec = Mat4x4Vec3_To_Vec3(gbufferModelView, sunVec);
sunVec = normalize(sunVec);
	
lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
