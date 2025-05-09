import 'package:flutter/material.dart';

class Question {
  String text;
  List<String> options;
  int correctIndex;
  Question(this.text, this.options, this.correctIndex);
}
