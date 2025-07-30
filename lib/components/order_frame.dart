import 'package:flutter/material.dart';

class OrderFrame extends StatelessWidget {

  final String status;
  final String orderName;
  final String amount;
  final DateTime date;
  final String counterpartName;

  const OrderFrame({super.key, required this.status, required this.orderName, required this.amount, required this.date, required this.counterpartName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(orderName),
                  Text(date.toLocal().toString().substring(0, 10))
                ],
              ),
              Text(status,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: status == 'Completed' ? Colors.green :  Color(0xFFF8B627)),)
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Amount'),
              Text('₦$amount', style: TextStyle(fontWeight: FontWeight.w900),)
            ],
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fees'),
              Text('₦0.00')
            ],
          ),
          SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(counterpartName),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Color(0xFF177E85),
                ),
                  onPressed: ( ) {},
                  icon: Icon(Icons.chat),
              )
            ],
          )
        ],
      ),
    );
  }
}
