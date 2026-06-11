import 'package:intl/intl.dart';

NumberFormat decimalFormat(String locale) => NumberFormat('#,##0.00', locale);

NumberFormat decimalFormatWithDecimals(String locale, int decimalPlaces) {
  if (decimalPlaces == 0) return NumberFormat('#,##0', locale);
  final pattern = '#,##0.${'0' * decimalPlaces}';
  return NumberFormat(pattern, locale);
}

double? parseDecimalInput(String value) {
  var s = value.trim();
  final hasDot = s.contains('.');
  final hasComma = s.contains(',');
  if (hasComma && hasDot) {
    s = s.replaceFirst(',', '');
  } else if (hasComma) {
    s = s.replaceAll(',', '.');
  }
  return double.tryParse(s);
}
