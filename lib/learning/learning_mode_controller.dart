import 'package:flutter/material.dart';

enum LearningMode { beginner, student, finance }

class LearningModeController {
  static ValueNotifier<LearningMode> currentMode = ValueNotifier(
    LearningMode.beginner,
  );
}
