import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecentFrame extends StatelessWidget {

  final String beneficiary;
  final DateTime date;
  final String status;
  final String amount;
  const RecentFrame({super.key, required this.beneficiary, required this.date, required this.amount, required this.status});

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
    return Column(
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
                      Text('$beneficiary', style: TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 12),),
                      Text('₦$amount', style: TextStyle(fontWeight: FontWeight.w900),)
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd MMM yyyy').format(date), style: TextStyle(fontWeight: FontWeight.w700),),
                      Text(status, style: TextStyle(color: Colors.green),)
                    ],
                  )
                ],
              ),
            )
          ],
        ),
        Divider()
      ],
    );
  }
}
