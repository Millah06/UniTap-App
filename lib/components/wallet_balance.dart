import 'package:everywhere/constraints/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceText extends StatelessWidget {
  final double amount;
  final double biggerSize;
  final double smallerSize;
  final Color ?  color;

  const BalanceText(this.amount, this.biggerSize, this.smallerSize,
      {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');
    final formatted = formatter.format(amount); // e.g. "2,000.45"
    final parts = formatted.split('.'); // ["2,000", "45"]

    return Text.rich(
        TextSpan(
          style: TextStyle(
            fontFamily: 'DejaVu Sans'
          ),
            children: [
              TextSpan(
                text: parts[0],
                style: TextStyle(
                  fontSize: biggerSize, // big integer part
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'DejaVu Sans',
                ),
              ),
              TextSpan(
                text: '.${parts[1]}',
                style: TextStyle(
                  fontSize: smallerSize, // smaller decimal part
                  color: color,
                  fontWeight: FontWeight.w900
                ),
              ),
            ],
            ),
        );
    }
}