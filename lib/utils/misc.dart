import 'package:intl/intl.dart';

bool equalsIgnoreCase(String string1, String string2) {
  return string1.toLowerCase() == string2.toLowerCase();
}

String doubleFormatUS(double doubleToFormat) {
  final numberFormat = NumberFormat("#,##0.##", "en_US");
  return numberFormat.format(doubleToFormat);
}

String intFormatUS(int intToFormat) {
  final numberFormat = NumberFormat("#,##0", "en_US");
  return numberFormat.format(intToFormat);
}