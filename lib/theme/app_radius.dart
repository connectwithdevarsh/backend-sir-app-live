import 'package:flutter/material.dart';

/// AppRadius defines standardized corner radius tokens.
class AppRadius {
  AppRadius._();

  static const double chip = 8.0;
  static const double button = 12.0;
  static const double input = 16.0;
  static const double card = 20.0;
  static const double heroCard = 24.0;
  static const double pill = 32.0;

  // BorderRadius Helpers
  static final BorderRadius chipBorder = BorderRadius.circular(chip);
  static final BorderRadius buttonBorder = BorderRadius.circular(button);
  static final BorderRadius inputBorder = BorderRadius.circular(input);
  static final BorderRadius cardBorder = BorderRadius.circular(card);
  static final BorderRadius heroBorder = BorderRadius.circular(heroCard);
  static final BorderRadius pillBorder = BorderRadius.circular(pill);
}
