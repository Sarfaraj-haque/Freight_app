import 'package:intl/intl.dart';

class AppUtils {
  AppUtils._();

  static final NumberFormat _rupeesFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String formatCurrency(double amount) {
    return _rupeesFormat.format(amount.abs());
  }

  static String formatCurrencyWithSign(double amount) {
    if (amount < 0) return '-${_rupeesFormat.format(amount.abs())}';
    return _rupeesFormat.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateForInput(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime? parseDate(String dateStr) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  static String formatWeight(double weight) {
    return '${weight.toStringAsFixed(1)} T';
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
