import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TextFieldFormater extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(',', '');
    if (text.isEmpty) return newValue;
    String newText = NumberFormat('#,##0').format(int.parse(text));
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length)
    );
    // TODO: implement formatEditUpdate

  }
}