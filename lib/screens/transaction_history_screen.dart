import 'package:cloud_firestore/cloud_firestore.dart';
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
  ValueNotifier<String> filter = ValueNotifier('All');

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
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: ValueListenableBuilder<String>(
              valueListenable: filter,
              builder: (_, value, __) {
                return Row(
                  children: ['All', 'Today', 'This Month', 'This Year']
                      .map((option) => Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: ChoiceChip(
                      label: Text(option,),
                      labelStyle:
                      TextStyle(fontSize: 9, color: value == option
                          ? Colors.white : Color(0xFF177E85), ),
                      selectedColor: Color(0xFF177E85),
                      backgroundColor: Color(0x8AFFFFFF),
                      selected: value == option,
                      checkmarkColor: Colors.white,
                      onSelected: (_) async {
                        filter.value = option;
                        // await pov.fetchTransactions(); // Only needed if fetching fresh data
                      },
                    ),
                  )).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: filter,
              builder: (_, selectedFilter, __) {
                // Flatten all user transactions from the map
                List<Map<String, dynamic>> allTx = pov.transactions;
                // Filter transactions
                final filtered = allTx.where((tx) {
                  final date = (tx['Date'] as Timestamp).toDate();
                  switch (selectedFilter) {
                    case 'Today':
                      return date.year == now.year &&
                          date.month == now.month &&
                          date.day == now.day;
                    case 'This Month':
                      return date.year == now.year &&
                          date.month == now.month;
                    case 'This Year':
                      return date.year == now.year;
                    default:
                      return true;
                  }
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No Transactions yet'));
                }

                return ReusableCard(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final transaction = filtered[index];

                      return RecentFrame(
                        beneficiary: transaction['Product Name'] ?? '',
                        date: (transaction['Date']).toDate(),
                        amount: (transaction['Paid Amount'] as num).toString(),
                        status: transaction['Status'] ?? 'failed',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ViewReceipt(transactionID: transaction['Transaction ID']),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
