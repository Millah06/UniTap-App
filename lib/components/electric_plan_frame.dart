import 'package:flutter/material.dart';

import '../constraints/constants.dart';

class ElectricPlanFrame extends StatelessWidget {

  const ElectricPlanFrame({super.key, required this.amount,
     required this.onTap, this.cashBack});

  final String amount;
  final Function() onTap;
  final String? cashBack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 70,
            height: 60,
            decoration: BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [BoxShadow(color: Color(0xFF177E85).withOpacity(0.4),
                    blurRadius: 4, spreadRadius: 1, offset: Offset(0, 2))]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(kNaira, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),),
                    Text(amount, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,),)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('pay', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white54),),
                    SizedBox(width: 5,),
                    Text(kNaira, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),),
                    Text(amount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,),)
                  ],
                ),
              ],
            )
          ),
          SizedBox(height: 2,),
          Padding(
              padding: EdgeInsetsGeometry.only(
                  bottom: 0, left: 0),
              child:  Container(
                margin: EdgeInsetsGeometry.only(left: 12),
                decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(0)
                ),
                child: Text('$kNaira$cashBack cashback ',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),),
              ),
          ),
        ],
      ),
    );
  }
}
