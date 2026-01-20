import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatETB(double amount) {
    final format = NumberFormat.currency(locale: 'en_ET', symbol: 'ETB ');
    return format.format(amount);
  }
}
