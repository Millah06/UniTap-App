import 'package:everywhere/components/reusable_card.dart';
import 'package:everywhere/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/recent_frame.dart';
import '../components/view_receipt.dart';
import '../services/brain.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {

  ValueNotifier<String>  filter = ValueNotifier('All');
  Color colo = Colors.black;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pov = Provider.of<Brain>(context);
    DateTime now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30,),
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: ValueListenableBuilder<String>(
                valueListenable: filter,
                builder: (_, value, __) {
                  return Row(
                    children: [
                      'All', 'Today', 'This Month', 'This Year',
                    ].map((option) {
                      return  Padding(
                        padding: EdgeInsets.only(left: 2),
                        child: ChoiceChip(
                            label: Text(option,),
                            labelStyle:
                            TextStyle(fontSize: 9, color: value == option
                                ? Colors.white : Color(0xFF177E85), ),
                            selectedColor: Color(0xFF177E85),
                            backgroundColor: Color(0x8AFFFFFF),
                            selected: value == option,
                            checkmarkColor: Colors.white,
                            onSelected: (_) {
                              setState(() async {
                                filter.value = option;
                                colo = Colors.white;
                                await pov.fetchTransactions();
                              });
                            }
                        ),);
                    }).toList(),
                  );
                }
            ),
          ),
          SizedBox(height: 10,),
          Expanded(
            child: pov.transactions.isEmpty ?
            Center(child: Text('No Transactions yet'),) :
            ReusableCard(
              child: ListView.builder(
                padding: EdgeInsets.only(left: 0, right: 0),
                itemBuilder: (BuildContext context, int index) {
                  // final transaction = pov.transactions[index]
                  //     .values.where((d) {
                  //   switch (filter.value) {
                  //     case 'Today' :
                  //       return  d.date.year == now.year && d.date.month == now.month && d.date.day == now.day;
                  //     case 'This Month' :
                  //       return  d.date.year == now.year && d.date.month == now.month;
                  //     case 'This Year' :
                  //       return d.date.year == now.year;
                  //     default:
                  //       return true;
                  //   }
                  // }
                  // ).toList()[index];
                  final transaction = pov.transactions[index];
                  return RecentFrame(
                      beneficiary: transaction['Product Name'],
                      date:  DateTime.now(),
                      amount: transaction['Amount'],
                      status: transaction['Amount'],
                    onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => ViewReceipt(receiptData: transaction,)));
                        },
                  );
                },
                itemCount: pov.transactions.length,
              ),

            ),
          )
        ],
      ),
    );
  }
}

