import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AnimatedBalanceWidget extends StatelessWidget {
  final String userId;
  final String currencySymbol;

  AnimatedBalanceWidget({
    required this.userId,
    this.currencySymbol = '₦',
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          double balance = (snapshot.data!.get('walletBalance') ?? 0).toDouble();

          final formatter = NumberFormat('#,##0.00');
          final formatted = formatter.format(balance); // e.g. 2,000.45
          final parts = formatted.split('.'); // ["2,000", "45"]

          return AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Text.rich(
              key: ValueKey(formatted),
              TextSpan(
                children: [
                  TextSpan(
                    text: '$currencySymbol${parts[0]}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: '.${parts[1]}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
          );
          },
       );
    }
}