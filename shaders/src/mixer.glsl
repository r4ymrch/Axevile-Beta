float dayAux = pow(timeAngle - 0.25, 2.0);
float nightAux = pow(timeAngle - 0.75, 2.0);

dayMixer = clamp(-dayAux * 20.0 + 1.25, 0.0, 1.0);
nightMixer = clamp(-nightAux * 50.0 + 3.125, 0.0, 1.0);