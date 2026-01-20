enum CpoType { percentage, fixed }

class CpoCalculator {
  static double calculate({
    required double bidAmount,
    required CpoType type,
    required double value, // Percentage (e.g., 1.0 for 1%) or Fixed Amount
  }) {
    if (type == CpoType.fixed) {
      return value;
    } else {
      return bidAmount * (value / 100);
    }
  }
}
