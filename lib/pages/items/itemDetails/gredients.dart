import 'package:flutter/material.dart';

LinearGradient bgGradient = LinearGradient(
  colors: [const Color(0xFFD983BD), const Color(0xFFFFE6EB)],
  tileMode: TileMode.clamp,
  begin: Alignment.bottomLeft,
  end: Alignment.topCenter,
  stops: [0.0, 0.99],
);
LinearGradient bgGradientII = LinearGradient(
  colors: [const Color(0xFFFFFFFF), const Color(0xFFECB6D5)],
  tileMode: TileMode.repeated,
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  stops: [0.0, 0.99],
);

LinearGradient btnGradient = LinearGradient(
  colors: [Color(0xFF61259e), const Color(0xFFb092ce)],
  tileMode: TileMode.clamp,
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  stops: [0.0, 1.0],
);

LinearGradient btnGradientII = new LinearGradient(
  colors: [const Color(0xFF37ecba), const Color(0xFF72afd3)],
  tileMode: TileMode.clamp,
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  stops: [0.0, 1.0],
);
