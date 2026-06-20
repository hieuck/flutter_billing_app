import 'package:intl/intl.dart';

class CurrencyHelper {
  static final _vndFormat = NumberFormat.currency(symbol: '₫', decimalDigits: 0);

  static String format(double amount) => _vndFormat.format(amount);
}
