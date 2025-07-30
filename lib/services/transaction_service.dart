import 'dart:io';
import 'dart:ui' as ui;
import 'package:another_flushbar/flushbar.dart';
import 'package:everywhere/components/dash_line.dart';
import 'package:everywhere/components/flush_bar_message.dart';
import 'package:everywhere/components/reusable_card.dart';
import 'package:everywhere/components/zig-za.dart';
import 'package:everywhere/services/receipt_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../components/transacrtion_pin.dart';
import '../components/wallet_balance.dart';
import '../constraints/constants.dart';
import 'brain.dart';

class TransactionService {
  static void handlePurchase({
    required BuildContext context,
    required Future<Map<String, dynamic>?> Function() purchaseFunction,
    required Future<void> Function() onSuccessExtras,
    required Future<void> Function() onFailureExtras,
    required String amount,
    Map<String, dynamic> ? Function(Map<String, dynamic> res) ? buildData,
  }) {
    String pin = '';
    final pov = Provider.of<Brain>(context, listen: false);

    // showModalBottomSheet(
    //   context: context,
    //   isDismissible: false,
    //   builder: (_) {
    //     return Padding(
    //       padding: const EdgeInsets.all(16),
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           const Text(
    //             'Enter Transaction PIN',
    //             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    //           ),
    //           const SizedBox(height: 12),
    //           TextField(
    //             obscureText: true,
    //             maxLength: 4,
    //             keyboardType: TextInputType.number,
    //             onChanged: (val) => pin = val,
    //             decoration: const InputDecoration(hintText: ''),
    //           ),
    //           const SizedBox(height: 12),
    //           ElevatedButton(
    //             onPressed: () async {
    //               Navigator.pop(context); // Close the sheet
    //
    //               // Show loading with back button disabled
    //               showDialog(
    //                 context: context,
    //                 barrierDismissible: false,
    //                 builder: (_) => WillPopScope(
    //                   onWillPop: () async => false,
    //                   child: const Center(child: CircularProgressIndicator()),
    //                 ),
    //               );
    //
    //               try {
    //                 final result = await purchaseFunction;
    //
    //                 Navigator.pop(context); // Remove loading dialog
    //
    //                 if (result['status'] == true) {
    //                   // Store transaction in Firestore
    //                   await FirebaseFirestore.instance.collection('transactions').add({
    //                     'transactionId': result['transactionId'],
    //                     'variationCode': result['variationCode'],
    //                     'amount': result['amount'],
    //                     'userId': result['userId'] ?? '',
    //                     'timestamp': FieldValue.serverTimestamp(),
    //                   });
    //
    //                   await onSuccessExtras();
    //
    //                   _showResultDialog(context, true);
    //                 } else {
    //                   await onFailureExtras();
    //
    //                   _showResultDialog(context, false, errorMessage: result['message']);
    //                 }
    //               } catch (e) {
    //                 Navigator.pop(context); // Remove loading
    //
    //                 String errorMsg = "An error occurred.";
    //                 if (e is SocketException) {
    //                   errorMsg = "No internet connection.";
    //                 }
    //
    //                 _showResultDialog(context, false, errorMessage: errorMsg);
    //               }
    //             },
    //             child: const Text('Continue'),
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    // );

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        isDismissible: false,
        builder: (_) =>
        TransactionPin(
          onCompleted: (pin ) async {
            if (pin == pov.localPIN) {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => PopScope(
                  canPop: false,
                  child: const Center(child: CircularProgressIndicator(
                    value: 20,
                    backgroundColor: kCardColor,
                    color: kButtonColor,
                  ),),
                ),
              );
              try {
                final result = await purchaseFunction();

                if (context.mounted) {
                  Navigator.pop(context); // Remove loading dialog
                }

                if (result?['status'] == true) {
                  // Store transaction in Firestore
                  // await FirebaseFirestore.instance.collection('transactions').add({
                  //   'transactionId': result['transactionId'],
                  //   'variationCode': result['variationCode'],
                  //   'amount': result['amount'],
                  //   'userId': result['userId'] ?? '',
                  //   'timestamp': FieldValue.serverTimestamp(),
                  // });

                  await onSuccessExtras();

                  // pov.addTransaction(amount, buildData!(result!)!);
                  pov.addTransaction(amount, buildData!(result!)!);


                  if (context.mounted) {
                     Navigator.pushReplacement(context,
                         MaterialPageRoute(builder: (context) =>
                             _showResult(context,
                                 true, amount, token: result['token'],
                               receiptData: buildData(result),
                             ),

                         ));
                  }
                } else {
                  await onFailureExtras();

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) =>
                          _showResult(context, false, '0.00',
                              errorMessage: result?['message'])));
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Remove loading
                }

                String errorMsg = "An error occurred.";
                if (e.toString().contains('SocketException')) {
                  errorMsg = "No internet connection.";
                }
                if (e.toString().contains('HandshakeException')) {
                  errorMsg = "No stable internet connection, please try again later.";
                }
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) =>
                        _showResult(context, false, '0.00', errorMessage: errorMsg)));
              }
            }
            else {
              Flushbar(
                title: 'Ops',
                message: 'Incorrect PIN!, try again.',
                borderRadius: BorderRadius.circular(12),
                backgroundColor: kErrorBackground,
                flushbarPosition: FlushbarPosition.TOP,
                icon: Icon(Icons.error_outline,
                  color: Colors.white, size: 30,),
                duration: Duration(seconds: 3),
                margin: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ).show(context);
            }
          },
          onForgotPin: () {  },
        )
    );
  }
  
  static Widget _showResult(BuildContext context, bool success, String tranAmount,
      {String? errorMessage, String? token, Map<String, dynamic>? receiptData}) {
    return Scaffold(
      body: FractionallySizedBox(
        heightFactor: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(top: 45, left: 15, right: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);},
                    child: Container(
                      alignment: Alignment.topRight,
                      child: Text('Done', style: TextStyle(
                          fontSize: 20, color: Colors.white,
                          fontWeight: FontWeight.bold, fontFamily: 'DejaVu Sans', ),),
                    ),
                  ),
                  SizedBox(height: 30,),
                  FaIcon(success ? FontAwesomeIcons.trophy : FontAwesomeIcons.xmark,
                    color: success ? Color(0xFF21D3ED)
                        : Colors.pink, size: 45, shadows: [
                          Shadow(
                            color: Colors.blue.withOpacity(0.5),
                            offset: Offset(3, 3),
                            blurRadius: 20
                          )
                    ],),
                  SizedBox(height: 30,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Text(kNaira, style: TextStyle(fontSize: 18,
                          fontWeight: FontWeight.bold, fontFamily: 'Courier', color: kButtonColor),),
                      SizedBox(width: 2,),
                      BalanceText(double.parse(tranAmount), 40, 18, color: kButtonColor,),
                      SizedBox(width: 7,),
                    ],
                  ),
                  Text(DateFormat('MMMM dd, yyyy hh:mm a').
                  format(DateTime.now())),
                  SizedBox(height: 15,),
                  Text(
                    success
                        ? 'Transaction Completed Successfully.'
                        : errorMessage ?? 'Transaction failed.', style: TextStyle(
                    fontSize: 14, // big integer part
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'DejaVu Sans',
                  ), textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20,),
                  if (token != null && token != '')
                    Text('Copy your token: ',
                      style: TextStyle(
                        fontFamily:  'Courier',
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 16,
                      ),),
                  SizedBox(width: 15,),
                  if (token != null && token != '')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(token,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily:  'Courier',
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                          fontSize: 17,
                          color: Colors.pink
                      ),),
                      SizedBox(width: 5,),
                      GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: token));
                            FlushBarMessage
                                .showFlushBar(
                                context: context,
                                message: 'Token Copied Successfully!'
                            );
                          },
                          child: Icon(Icons.copy, size: 20,),
                        )
                    ],
                  ),

                ],
              ),
            ),
            Visibility(
              visible: success,
              child: Container(
                padding: EdgeInsets.only(bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => viewReceipt(context, receiptData!) ));
                      },
                      child: ReusableCardReceipt(
                        text: 'View Receipt',
                        myIcon: Icon(Icons.receipt),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await ReceiptBuilder().exportToPdf(receiptData!);
                      },
                      child: ReusableCardReceipt(
                        text: 'Share Receipt',
                        myIcon: Icon(Icons.share),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  static Widget viewReceipt(BuildContext context, Map<String, dynamic> receiptData) {
    final GlobalKey previewKey = GlobalKey();

    Future<void> generateAndShareImage() async {
      try {
        RenderRepaintBoundary boundary =
        previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

        ui.Image image = await boundary.toImage(pixelRatio: 3.0); // High quality
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        // Save to temporary directory
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/gift_card.png';
        File imgFile = File(filePath);
        await imgFile.writeAsBytes(pngBytes);

        // // Share the image
        // await Share.shareFiles([filePath], text: "Here’s your surprise gift! ❤️");

        await SharePlus.instance.share(
          ShareParams(
              files:  [XFile(filePath)],
              title: 'Smart Spend Pdf Expense Report',
              text: 'Here’s your surprise gift! ❤️'
          ),
        );

      } catch (e) {
        print("Error generating image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong. Try again!')),
        );
      }
    }
    // final logoBytes = await rootBundle.load('images/eraser.png');
    //
    // final logoWaterMark = MemoryImage(logoBytes.buffer.asUint8List());
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RepaintBoundary(
            key: previewKey,
            child: Container(
              margin: EdgeInsets.only(left: 20, right: 20, top: 40),
              padding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 15),
              width: double.infinity,
              decoration: BoxDecoration(
                // color: Color(0xFF177E85),
                  color: Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Color(0xFF177E85).withOpacity(0.4),
                      blurRadius: 8, spreadRadius: 1, offset: Offset(0, 2))]
              ),
              child: Stack(
                children: [
                  Opacity(
                    opacity: 0.1,
                    child: SizedBox(
                      height: 450,
                      width: double.infinity,
                      child: GridView(
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1
                        ),
                        children: List.generate(28, (index) =>
                            Center(
                              child: Transform.rotate(
                                  angle: 0.5,
                                  child: Image(
                                    image: AssetImage('images/eraser.png'),
                                    width: 50,
                                    height: 50,
                                  )
                              ),
                            ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(top: 10),
                    child: SizedBox(
                      height: 200,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset('images/eraser.png', height: 65, width: 65,),
                              Text('Transaction Receipt', style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'DejaVu Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold
                              ),)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            children: [
                              Text(kNaira, style: TextStyle(fontSize: 18,
                                  fontWeight: FontWeight.bold, fontFamily: 'Courier', color: kButtonColor),),
                              SizedBox(width: 2,),
                              BalanceText(
                                  double
                                      .parse(
                                      receiptData['Amount'].split(' ').first
                                  ), 30, 18, color: kButtonColor),
                              SizedBox(width: 0,),
                            ],
                          ),
                          Text('Successful', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                          Text(DateFormat('MMMM dd, yyyy hh:mm a').
                          format(DateTime.now())),
                          Divider(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 180),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ...List.generate(receiptData.length, (index)
                          {
                            String key = receiptData.keys.toList()[index];
                            String value = receiptData.values.toList()[index];
                            return Column(
                              children: [
                                key == 'Transaction ID' || key == 'Token' ?
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(key,
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontFamily: 'OpenSans',
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold
                                        ),),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(value,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                // fontFamily:  'Courier',
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.underline,
                                                decorationColor: Colors.white,
                                                fontSize: 14,
                                                color: Colors.pink
                                            ),),
                                          SizedBox(width: 5,),
                                          GestureDetector(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(text: value));
                                              FlushBarMessage
                                                  .showFlushBar(
                                                  context: context,
                                                  message: 'Token Copied Successfully!'
                                              );
                                            },
                                            child: Icon(Icons.copy, size: 15,),
                                          )
                                        ],
                                      ),
                                    ],
                                  ) :
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(key,
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontFamily: 'OpenSans',
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text(value,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'OpenSans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ],
                                ),
                                SizedBox(height: 15,)
                              ],
                            );
                          }
                          ),
                          SizedBox(height: 40,),
                          DashedLine(height: 1,),
                          SizedBox(height: 10,),
                          Text('Enjoy a better life with ElitePay. Book flight, book hotel, spend in foreign currencies, get '
                              'virtual foreign cards, pay all your bills',
                            style: TextStyle(color: Colors.white70, fontSize: 12),)
                        ]
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
              color: Color(0xFF1E293B),
            height: 70,
            child: Padding(
              padding: EdgeInsetsGeometry.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await ReceiptBuilder().exportToPdf(receiptData);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exporting your report...')),
                      );
                    },
                    child: Container(
                      padding: EdgeInsetsGeometry.symmetric(
                          vertical: 8, horizontal: 30),
                      decoration: BoxDecoration(
                        color: kButtonColor,
                        border: Border.all(
                          color: Colors.white70,
                          width: 1.5
                        ),
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text('Share as PDF', style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'DejaVu Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                  ),
                  Center(child: VerticalDivider(color: Colors.white30,),),
                  GestureDetector(
                    onTap: generateAndShareImage,
                    child: Container(
                      padding: EdgeInsetsGeometry.symmetric(
                          vertical: 8, horizontal: 30),
                      decoration: BoxDecoration(
                          color: kButtonColor,
                          border: Border.all(
                              color: Colors.white70,
                              width: 1.5
                          ),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text('Share as Image', style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'DejaVu Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

}
