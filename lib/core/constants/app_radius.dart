import 'package:flutter/material.dart';

abstract class AppRadius {
  static const double smVal = 12.0;
  static const double mdVal = 20.0;
  static const double pillVal = 30.0;

  static const BorderRadius sm = BorderRadius.all(Radius.circular(smVal));
  static const BorderRadius md = BorderRadius.all(Radius.circular(mdVal));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(mdVal));
  static const BorderRadius radiusLg = BorderRadius.all(
    Radius.circular(mdVal),
  ); // Alias to resolve legacy errors
  static const BorderRadius pill = BorderRadius.all(Radius.circular(pillVal));

  static const BorderRadius topSheet = BorderRadius.only(
    topLeft: Radius.circular(32.0),
    topRight: Radius.circular(32.0),
  );
}
