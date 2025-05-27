import 'package:flutter/material.dart';

class CategoryBoxShadow {
  static final verticalProductShadow = BoxShadow(
    color: Color.fromARGB(86, 95, 95, 97),
    blurRadius: 50,
    spreadRadius: 7,
    offset: const Offset(0, 2),
  );

  static final horizontalProductShadow = BoxShadow(
    color: Color.fromARGB(86, 95, 95, 97),
    blurRadius: 50,
    spreadRadius: 7,
    offset: Offset(0, 2),
  );
}
