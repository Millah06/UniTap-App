import 'package:everywhere/constraints/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'formatters.dart';

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

    IconData getIcon() {
      IconData theIcon;
      beneficiary.contains('Airtime') ? theIcon = Icons.phone :
      beneficiary.contains('Data') ? theIcon = Icons.wifi :
      beneficiary.contains('Candidates') ? theIcon = FontAwesomeIcons.graduationCap :
      beneficiary.contains('Electricity') ? theIcon = Icons.bolt_outlined :
       theIcon = Icons.receipt;
      return theIcon;
    }


    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Transform.scale(
                scale: 0.9,
                child: CircleAvatar(
                    backgroundColor: Color(0xFF177E85),
                    child: Icon(getIcon(), color: Colors.white,)),
              ),
              SizedBox(width: 5,),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(beneficiary, style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w700, fontSize: 10), softWrap: false,),
                        ),
                        Text('₦${kFormatter.format(double.tryParse(amount.split(' ').first))}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400, fontSize: 12),)
                      ],
                    ),
                    SizedBox(height: 3,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(MyFormatManager.formatMyDate(date, 'MMMM d, yyyy hh:mm a'),
                          style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 10),),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                            decoration: BoxDecoration(
                                color: Color(0xFF177E85),
                                borderRadius: BorderRadius.circular(10)
                          ),
                          child: Text(status, style:
                          GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 6),),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
          Divider(color: Colors.white54,)
        ],
      ),
    );
  }
}


