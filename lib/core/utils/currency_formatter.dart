import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static final _compactFormatter = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static String format(int amount) => _formatter.format(amount);

  static String formatCompact(int amount) => _compactFormatter.format(amount);

  static String formatSigned(int amount, {bool isExpense = true}) {
    final prefix = isExpense ? '-' : '+';
    return '$prefix${_formatter.format(amount.abs())}';
  }
}
