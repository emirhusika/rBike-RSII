import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String formatNumber(dynamic value) {
  if (value == null) {
    return "";
  }

  var f = NumberFormat.currency(locale: 'bs_BA', symbol: '', decimalDigits: 2);
  return f.format(value);
}

Image imageFromString(String input) {
  return Image.memory(base64Decode(input));
}
