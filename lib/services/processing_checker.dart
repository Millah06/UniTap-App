
import 'package:everywhere/services/purchase_service.dart';
import 'package:everywhere/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constraints/constants.dart';
import 'brain.dart';

class ProcessingChecker extends StatefulWidget {
  final bool success;
  final double tranAmount;
  final String? errorMessage;
  final String? token;
  final String? serial;
  final Map<String, dynamic>? receiptInformation;

  const ProcessingChecker({
    super.key,
    required this.success,
    required this.tranAmount,
    this.errorMessage,
    this.token,
    this.serial,
    this.receiptInformation,
  });

  @override
  State<ProcessingChecker> createState() => _ProcessingCheckerState();
}

class _ProcessingCheckerState extends State<ProcessingChecker> {
  late bool success;
  late double tranAmount;
  late Map<String, dynamic>? receiptInfo;
  late String? errorMessage;
  bool processing = false;

  @override
  void initState() {
    super.initState();
    success = widget.success;
    tranAmount = widget.tranAmount;
    receiptInfo = widget.receiptInformation;
    errorMessage = widget.errorMessage;

    // Start polling if status is processing
    if (!success) {
      processing = true;
      _pollTransactionStatus();
    }
  }

  void _pollTransactionStatus() async {
    if (receiptInfo == null || receiptInfo!['transaction_id'] == null) return;

    String transactionId = receiptInfo!['transaction_id'];
    int attempts = 0;
    const maxAttempts = 6;
    const interval = Duration(seconds: 5);

    while (processing && attempts < maxAttempts && mounted) {
      await Future.delayed(interval);
      attempts++;

      final result = await PurchaseItems(context: context).checkTransactionStatus(transactionId);

      if (result['status'] != null) {
        setState(() {
          success = result['status'] == true;
          receiptInfo = result;
          errorMessage = result['status'] == false ? result['message'] : null;
          processing = false;
        });

        // Update provider automatically
        final pov = Provider.of<Brain>(context, listen: false);
        // await pov.addTransaction(result); // assumes your Brain method can accept Map
        break;
      }
    }

    if (processing && mounted) {
      setState(() {
        processing = false;
        errorMessage ??= 'Transaction still processing. Please refresh later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (processing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: kButtonColor),
            SizedBox(height: 20),
            Text(
              "Transaction is being processed...",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    // Show result content (success/failure)
    return TransactionService.showSuccessResult(context,
      success,
      errorMessage: errorMessage,
      receiptInformation: receiptInfo,
    );
  }
}