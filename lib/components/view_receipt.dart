import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everywhere/components/wallet_balance.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:another_flushbar/flushbar.dart';
import 'package:everywhere/components/dash_line.dart';
import 'package:everywhere/components/flush_bar_message.dart';
import 'package:everywhere/components/reusable_card.dart';
import 'package:everywhere/services/receipt_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constraints/constants.dart';
import '../services/brain.dart';
import 'formatters.dart';

class ViewReceipt extends StatelessWidget {

  final String transactionID;

  const ViewReceipt({super.key, required this.transactionID});



  @override
  Widget build(BuildContext context) {

    final GlobalKey previewKey = GlobalKey();

    final pov = Provider.of<Brain>(context);
    Map<String, dynamic> receiptData =
    pov.transactions.firstWhere((currentList) => currentList['Transaction ID'] == transactionID);

    DateTime date = receiptData['Date'] is Timestamp
        ? (receiptData['Date'] as Timestamp).toDate()
        : (receiptData['Date'] as DateTime);


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
              title: 'NexPay Transaction Receipt',
              text: 'Get yours → ${AppLinkHandler.appLink}'
          ),
        );

      } catch (e) {
        print("Error generating image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong. Try again!')),
        );
      }
    }

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
              margin: EdgeInsets.only(left: 12, right: 12, top: 40),
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
                                    image: AssetImage('images/receipt.png'),
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
                              Image.asset('images/receipt2.png', height: 65, width: 65,),
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
                              BalanceText(double.parse(receiptData['Paid Amount'].toString()), 30, 18, color: kButtonColor),
                              SizedBox(width: 0,),
                            ],
                          ),
                          Text(receiptData['Status'], style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),),
                          Text(DateFormat('MMMM dd, yyyy hh:mm a').
                          format(date), style: GoogleFonts.inter(),),
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
                            dynamic value = receiptData.values.toList()[index];
                            if (key == 'Status' || key == 'Date' || key == 'Paid Amount'
                                || key == 'pins' ||
                                key == 'waec_registration-tokens'
                                || key == 'waec_result_cards' || key == 'request_id') {
                              return SizedBox();
                            }
                            return Column(
                              children: [
                                key == 'Transaction ID' || key == 'Token' ?
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(key,
                                      style: GoogleFonts.inter(
                                          color: Colors.white60,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400
                                      ),),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(value,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            // fontFamily:  'Courier',
                                              fontWeight: FontWeight.w500,
                                              decoration: TextDecoration.underline,
                                              decorationColor: Colors.white,
                                              fontSize: 13,
                                              color: Colors.white
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
                                          child: Icon(Icons.copy, size: 15, color: kIconColor,),
                                        )
                                      ],
                                    ),
                                  ],
                                ) : key == 'Bonus Earned' ?
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(key,
                                      style: GoogleFonts.inter(
                                          color: Colors.white60,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400
                                      ),),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(value,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500,
                                              decorationColor: Colors.white,
                                              fontSize: 13,
                                              color: kIconColor
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
                                          child: Icon(Icons.gpp_good, size: 15, color: kIconColor,),
                                        )
                                      ],
                                    ),
                                  ],
                                ) :
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(key,
                                      style: GoogleFonts.inter(
                                          color: Colors.white60,

                                          fontSize: 13,
                                          fontWeight: FontWeight.w400
                                      ),),
                                    SizedBox(width: 15,),
                                    Flexible(
                                      child: Text(softWrap: false, value,
                                        style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500
                                        ),),
                                    ),
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
                          Text('Enjoy a better life with NexPay. Book flight, book hotel, spend in foreign currencies, get '
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Generating your receipt...'), backgroundColor: kCardColor,),
                      );
                      await ReceiptBuilder().exportToPdf(receiptData['Transaction ID'], context);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsetsGeometry.symmetric(
                          vertical: 8, horizontal: 15),
                      decoration: BoxDecoration(
                          color: kButtonColor,
                          border: Border.all(
                              color: Colors.white70,
                              width: 1.5
                          ),
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text(receiptData.containsKey('pin') ? 'Download PINS & Share' : 'Share as PDF' , style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                  ),
                  Center(child: VerticalDivider(color: Colors.white30,),),
                  GestureDetector(
                    onTap: generateAndShareImage,
                    child: Container(
                      padding: EdgeInsetsGeometry.symmetric(
                          vertical: 8, horizontal: 15),
                      decoration: BoxDecoration(
                          color: kButtonColor,
                          border: Border.all(
                              color: Colors.white70,
                              width: 1.5
                          ),
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text('Share as image', style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 14,
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
