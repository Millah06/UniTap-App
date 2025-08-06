import 'package:everywhere/constraints/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RecentFrame extends StatelessWidget {

  final String beneficiary;
  final Function() onTap;
  final DateTime date;
  final String status;
  final String amount;
  const RecentFrame({super.key, required this.beneficiary, required this.date,
    required this.amount, required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {

    IconData _getTransactionIcon() {
      switch (beneficiary) {
        case 'airtime' : return Icons.phone;
        case 'data' : return Icons.wifi;
        case 'electricity unit': return Icons.bolt_outlined;
        default: return Icons.receipt;
      }
    }
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Color(0xFF177E85)
                ),
                  onPressed: ( ) {},
                  icon: Icon(_getTransactionIcon(),)),
              SizedBox(width: 5,),
              Expanded(

                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$beneficiary', style: GoogleFonts.inter(
                            fontWeight: FontWeight.w900, fontSize: 11),),
                        Text('₦${kFormatter.format(double.tryParse(amount.split(' ').first))}', style: GoogleFonts.inter(
                            fontWeight: FontWeight.w900),)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd MMM yyyy').format(date),
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 10),),
                        Text('successful', style: GoogleFonts.inter(color: kButtonColor),)
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}
