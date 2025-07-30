import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {
  const ReusableCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 10, left: 15, right: 15, top: 10),
      margin: EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFF1E293B),
      ),
      child: child
    );
  }
}

class ReusableCardReceipt extends StatelessWidget {
  const ReusableCardReceipt({super.key, required this.text, required this.myIcon});

  final String text;
  final Icon myIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
        width: double.infinity,
        padding: EdgeInsets.only(bottom: 10, left: 15, right: 15, top: 10),
        margin: EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFF1E293B),
          border: Border.all(
              color:  Color(0xFF21D3ED),
              width: 1.5
          )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            myIcon,
            SizedBox(width: 10,),
            Text(text, style: TextStyle(fontWeight: FontWeight.bold,
                fontFamily: 'Courier'),)
          ],
        )
    );
  }
}

class ReusableCard2 extends StatelessWidget {
  const ReusableCard2({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 0),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        // color: Color(0xFFE3E3E3),
        // color: Color(0xFF1E1E1E),
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
