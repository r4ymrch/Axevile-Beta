vec4 inColor = tintColor;
vec3 nColor = normalize(inColor.rgb);

if (nColor.g > nColor.b && inColor.a == 1.0) {
  albedo.rgb *= mix(nColor, inColor.rgb, 0.25);
} else {
  albedo.rgb *= (inColor.a == 0.0) ? inColor.rgb : sqrt(inColor.rgb);
}

albedo.a *= inColor.a;
albedo.rgb = SRGBToLinear(albedo.rgb);
