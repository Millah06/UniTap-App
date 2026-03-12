import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../components/formatters.dart';
import '../constraints/constants.dart';
import 'brain.dart';

class ReceiptBuilder {

  Future<void> exportToPdf(String ? transactionID, context, {Map<String, dynamic> ? myData}) async {

    final pov = Provider.of<Brain>(context, listen: false);

    Map<String, dynamic>? receiptData;



    receiptData =
    transactionID == '' ? myData :
    pov.transactions.firstWhere((currentList) => currentList['Transaction ID'] == transactionID);


    List<List<dynamic>> rows = [];

    PdfColor generateColor() {
      Random random = Random();
      double pastelStrength = 0.2;
      return PdfColor(
          (random.nextDouble() * (1-pastelStrength)),
          (random.nextDouble() * (1-pastelStrength)),
          (random.nextDouble() * (1-pastelStrength))
      );
    }
    final pdf = pw.Document();

    final logoBytes = await rootBundle.load('images/receipt.png');

    final logoWaterMark = pw.MemoryImage(logoBytes.buffer.asUint8List());

    final smallBytes = await rootBundle.load('images/gift.png');

    final smallLogo = pw.MemoryImage(smallBytes.buffer.asUint8List());

    DateTime date = receiptData?['Date'] is Timestamp
        ? (receiptData?['Date'] as Timestamp).toDate()
        : (receiptData?['Date'] as DateTime);

    bool isRechargeCard = receiptData?.containsKey('pins') ?? true;
    bool isWaecRegistrationTokens = receiptData?.containsKey('waec_registration-tokens') ?? true;
    bool isWaecResultPin = receiptData?.containsKey('waec_result_cards') ?? true;


    String ? businessName;
    List ? rechargePins;
    List ? rechargeSerial;
    String ? network;
    String instruction = 'Dial *555#';
    int ? numberOfCards;
    double ? amount;

    List ? waecRegistrationTokens;

    List ? waecResultCards;

    if (isRechargeCard) {
      businessName = receiptData?['Business Name'];
      rechargePins = receiptData?['pins'];
      rechargeSerial = receiptData?['serial'];
      network = receiptData?['Product Name'].split(' ').first;
      double totalAmount = double.parse(receiptData?['Actual Amount'].split(' ').first);
      numberOfCards = int.parse(receiptData?['numberOfCards']);
      print(totalAmount);
      amount = totalAmount / numberOfCards;

    }

    if (isWaecRegistrationTokens) {
      waecRegistrationTokens = List.from(jsonDecode(receiptData?['waec_registration-tokens']));
      double totalAmount = receiptData?['Paid Amount'];
      // numberOfCards = int.parse(receiptData?['numberOfCards']);
      numberOfCards = int.parse(receiptData?['Number Of Student']);
      print(totalAmount);
      amount = totalAmount / numberOfCards;

    }

    if (isWaecResultPin) {
      waecResultCards = jsonDecode(receiptData?['waec_result_cards']);
      double totalAmount = receiptData?['Paid Amount'];
      // numberOfCards = int.parse(receiptData?['numberOfCards']);
      numberOfCards = int.parse(receiptData?['Number Of Student']);
      print(totalAmount);
      amount = totalAmount / numberOfCards;

    }

    final font = await rootBundle.load('assets/fonts/DejaVuSans.ttf');
    final ttf = pw.Font.ttf(font.buffer.asByteData());
    pdf.addPage(
        pw.MultiPage(
            pageTheme: pw.PageTheme(
                buildBackground: (context) => pw.Center(
                    child: pw.Opacity(
                        opacity: 0.14,
                        child: pw.GridView(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            children: List.generate(21, (index) => pw.Center(
                                child: pw.Transform.rotate(
                                    angle: 0.6,
                                    child: pw.Container(
                                      width: 80,
                                      height: 80,
                                      child: pw.Container(
                                        child: pw.Image(logoWaterMark)
                                      )
                                    )
                                )
                            )
                             )
                        )
                    )
                )
            ),
            footer: (context) => pw.Container(
                margin: pw.EdgeInsets.only(top: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (isWaecRegistrationTokens || isRechargeCard)
                      pw.Padding(
                          padding: pw.EdgeInsets.only(top: 10, bottom: 10),
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('INSTRUCTION',
                                style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey)),
                            pw.Text('Go to the official WAEC e-Registration '
                                'portal:www.waeconline.org.ng — Click on "School Login" '
                                'or "Private Candidate Registration" '
                                '(whichever applies). — Enter your Registration '
                                'Token exactly as shown below. — Follow the on-screen'
                                ' steps to complete the registration',
                                style: pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.grey))
                          ]
                        ),
                      ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('©️ ${DateTime.now().year} NexPay. All rights reserved',  style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey) ),
                        pw.Text('Generated by NexPay | ${context.pageNumber} of ${context.pagesCount}',
                            style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey)),
                      ],
                    )
                  ]
                )
            ),
            header: (context) {
              if (context.pageNumber == 1) {
                return pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                      children: [
                                        pw.Image(smallLogo, width: 40, height: 40),
                                        pw.SizedBox(width: 5),
                                        pw.Text('NexPay', style: pw.TextStyle(fontSize: 25, fontWeight: pw.FontWeight.bold)),
                                      ]
                                  ),
                                  pw.SizedBox(height: 7),
                                  pw.Text('Your world of bills and gifts, in one tap.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                                ]
                            ),
                            pw.Text(isRechargeCard ? '$businessName' : 'Transaction Receipt', style: pw.TextStyle(
                                color: PdfColors.black,
                                font: ttf,
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold
                            ),)
                          ]
                      ),
                      pw.Divider(),
                      pw.SizedBox(height: 15),
                      pw.Center(
                          child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.center,
                                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                                  children: [
                                    pw.Text(
                                      '$kNaira${kFormatter.format(receiptData?['Paid Amount'])}',
                                      style: pw.TextStyle(fontSize: 28,
                                          fontWeight: pw.FontWeight.bold, font: ttf, color:
                                          PdfColor.fromHex('#1E293B')),),
                                    pw.SizedBox(width: 2,),
                                  ],
                                ),
                                pw.SizedBox(height: 10),
                                pw.Text('Successful',
                                  style: pw.TextStyle(color: PdfColors.black,
                                      fontWeight: pw.FontWeight.bold),),
                                pw.SizedBox(height: 10),
                                pw.Text(DateFormat('MMMM dd, yyyy hh:mm a').
                                format(date)),
                              ]
                          )
                      ),
                    ]
                );
              }
              return pw.SizedBox();
            },
            build: (context) {
              if (isRechargeCard) {
                return  [
                  pw.Column(
                      children: List.generate((numberOfCards! / 3).ceil(),
                              (rowsIndex) {
                            return pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: List.generate(3, (colIndex) {
                                  final index = rowsIndex * 3 + colIndex;
                                  print(index);
                                  String currentPin = rechargePins?[index];
                                  String currentSerial = rechargeSerial?[index];
                                  if (index >= numberOfCards!) return pw.SizedBox();
                                  return pw.Container(
                                    width: 135,
                                    padding: const pw.EdgeInsets.all(8),
                                    margin: pw.EdgeInsets.all(10),
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border.all(color: PdfColors.black, width: 1),
                                    ),
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                                      children: [
                                        pw.Text(
                                          "$network $kNaira$amount Airtime",
                                          style: pw.TextStyle(
                                              fontSize: 10,
                                              fontWeight: pw.FontWeight.bold,
                                              font: ttf
                                          ),
                                          textAlign: pw.TextAlign.center,
                                        ),
                                        pw.SizedBox(height: 4),
                                        pw.Text(
                                          "PIN:",
                                          style: pw.TextStyle(
                                              fontSize: 7, fontWeight: pw.FontWeight.bold),
                                        ),
                                        pw.Text(
                                          currentPin
                                              .replaceAllMapped(RegExp(r".{4}"), (m) => "${m.group(0)} "),
                                          style: pw.TextStyle(
                                            fontSize: 9,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                          textAlign: pw.TextAlign.center,
                                        ),
                                        pw.SizedBox(height: 3),
                                        pw.Text("Serial: $currentSerial", style: pw.TextStyle(fontSize: 6)),
                                        pw.SizedBox(height: 2),
                                        pw.Text(
                                          instruction ?? "",
                                          style: pw.TextStyle(fontSize: 6),
                                          textAlign: pw.TextAlign.center,
                                        ),
                                        pw.SizedBox(height: 3),
                                        pw.Divider(),
                                        pw.Text(
                                          "Powered by ${businessName ?? ''}",
                                          style: pw.TextStyle(fontSize: 6, fontStyle: pw.FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                  );
                                })
                            );
                          })
                  )
                ];
              }
              if (isWaecRegistrationTokens) {
                return  [
                  pw.SizedBox(height: 15),
                  pw.Text('Transaction Summary', style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        ...List.generate(receiptData!.length, (index)
                        {
                          String? key = receiptData?.keys.toList()[index];
                          dynamic value = receiptData?.values.toList()[index];

                          if (key == 'Status' || key == 'Date' ||
                              key == 'Paid Amount' ||
                              key == 'waec_registration-tokens' || key == 'request_id') {
                            return pw.SizedBox();
                          }

                          return pw.Column(
                              children: [
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(key!,
                                      style: pw.TextStyle(
                                          color: PdfColors.black,
                                          fontSize: 13,
                                          fontWeight: pw.FontWeight.bold
                                      ),),
                                    pw.Text(value,
                                      style: pw.TextStyle(
                                          color: PdfColors.black,
                                          fontSize: 14,
                                          fontWeight: pw.FontWeight.bold
                                      ),),
                                  ],
                                ),
                                pw.SizedBox(height: 15)
                              ]
                          );
                        }
                        ),
                      ]
                  ),
                  pw.SizedBox(height: 15),
                  pw.Text('Transaction Details', style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.GridView(
                    crossAxisCount: 3,
                    childAspectRatio: 0.6,
                    children: List.generate(numberOfCards!, (index) {
                      String currentToken = waecRegistrationTokens?[index];
                      if (index >= numberOfCards!) return pw.SizedBox();
                      return pw.Container(
                        alignment: pw.Alignment.center,
                        width: 100,
                        padding: const pw.EdgeInsets.all(5),
                        margin: pw.EdgeInsets.all(5),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.black, width: 1),
                        ),
                        child:  pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    "$kNaira$amount",
                                    style: pw.TextStyle(
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold,
                                        font: ttf
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                  pw.Text(
                                    "WAEC REG PIN",
                                    style: pw.TextStyle(
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold,
                                        font: ttf
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ]
                            ),
                            pw.SizedBox(height: 5),
                            pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    "TOKEN ${index + 1}:",
                                    style: pw.TextStyle(
                                        fontSize: 7, fontWeight: pw.FontWeight.bold, font: ttf),
                                  ),
                                  pw.Text(
                                    currentToken
                                        .replaceAllMapped(RegExp(r".{4}"), (m) => "${m.group(0)} "),
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ]
                            ),


                            pw.SizedBox(height: 3),
                            pw.Text("NOTE: ONCE used can't be reused.",
                              style: pw.TextStyle(fontSize: 6),
                              textAlign: pw.TextAlign.center,
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text('Date Issued: ${DateFormat('MMMM dd, yyyy hh:mm a').
                            format(date)}', style: pw.TextStyle(fontSize: 6),
                              textAlign: pw.TextAlign.center),
                            pw.SizedBox(height: 3),
                            pw.Divider(),
                            pw.Text(
                                "Powered by NexPay Issued to ${receiptData?['School Name']}",
                                style: pw.TextStyle(fontSize: 6, fontStyle: pw.FontStyle.italic), textAlign: pw.TextAlign.center
                            ),
                          ],
                        ),
                      );
                    })
                  ),

                ];
              }
              if (isWaecResultPin) {
                return  [
                  pw.SizedBox(height: 15),
                  pw.Text('Transaction Summary', style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        ...List.generate(receiptData!.length, (index)
                        {
                          String? key = receiptData?.keys.toList()[index];
                          dynamic value = receiptData?.values.toList()[index];

                          if (key == 'Status' || key == 'Date'
                              || key == 'Paid Amount'
                              || key == 'waec_registration-tokens' || key == 'request_id') {
                            return pw.SizedBox();
                          }

                          return pw.Column(
                              children: [
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(key!,
                                      style: pw.TextStyle(
                                          color: PdfColors.black,
                                          fontSize: 13,
                                          fontWeight: pw.FontWeight.bold
                                      ),),
                                    pw.Text(value,
                                      style: pw.TextStyle(
                                          color: PdfColors.black,
                                          fontSize: 14,
                                          fontWeight: pw.FontWeight.bold
                                      ),),
                                  ],
                                ),
                                pw.SizedBox(height: 15)
                              ]
                          );
                        }
                        ),
                      ]
                  ),
                  pw.SizedBox(height: 15),
                  pw.Text('Transaction Details', style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.GridView(
                      crossAxisCount: 3,
                      childAspectRatio: 0.63,
                      children: List.generate(numberOfCards!, (index) {
                        String currentPin = waecResultCards?[index]['Pin'];
                        String currentSerial = waecResultCards?[index]['Serial'];
                        if (index >= numberOfCards!) return pw.SizedBox();
                        return pw.Container(
                          alignment: pw.Alignment.center,
                          width: 100,
                          padding: const pw.EdgeInsets.all(5),
                          margin: pw.EdgeInsets.all(5),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 1),
                          ),
                          child:  pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                      "$kNaira$amount",
                                      style: pw.TextStyle(
                                          fontSize: 10,
                                          fontWeight: pw.FontWeight.bold,
                                          font: ttf
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                    pw.Text(
                                      "WAEC Result",
                                      style: pw.TextStyle(
                                          fontSize: 10,
                                          fontWeight: pw.FontWeight.bold,
                                          font: ttf
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ]
                              ),
                              pw.SizedBox(height: 5),
                              pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                      "PIN ${index + 1}:",
                                      style: pw.TextStyle(
                                          fontSize: 7, fontWeight: pw.FontWeight.bold, font: ttf),
                                    ),
                                    pw.Text(
                                      currentPin
                                          .replaceAllMapped(RegExp(r".{4}"), (m) => "${m.group(0)} "),
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ]
                              ),
                              pw.SizedBox(height: 3),
                              pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                      "Serial ${index + 1}:",
                                      style: pw.TextStyle(
                                          fontSize: 7, fontWeight: pw.FontWeight.bold, font: ttf),
                                    ),
                                    pw.Text(
                                      currentSerial
                                          .replaceAllMapped(RegExp(r".{4}"), (m) => "${m.group(0)} "),
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ]
                              ),
                              pw.SizedBox(height: 3),
                              pw.Text("NOTE: ONCE used can't be reused.",
                                style: pw.TextStyle(fontSize: 6),
                                textAlign: pw.TextAlign.center,
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text('Date Issued: ${DateFormat('MMMM dd, yyyy hh:mm a').
                              format(date)}', style: pw.TextStyle(fontSize: 6),
                                  textAlign: pw.TextAlign.center),
                              pw.SizedBox(height: 3),
                              pw.Divider(),
                              pw.Text(
                                  "Powered by NexPay Issued to ${receiptData?['School Name']}",
                                  style: pw.TextStyle(fontSize: 6, fontStyle: pw.FontStyle.italic), textAlign: pw.TextAlign.center
                              ),
                            ],
                          ),
                        );
                      })
                  ),

                ];
              }
              return [
                pw.SizedBox(height: 30),
                pw.Text('Transaction Details', style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      ...List.generate(receiptData!.length, (index)
                      {
                        String? key = receiptData?.keys.toList()[index];
                        dynamic value = receiptData?.values.toList()[index];

                        if (key == 'Status' || key == 'Date'
                            || key == 'Paid Amount'
                            || key == 'waec_registration-tokens' || key == 'request_id') {
                          return pw.SizedBox();
                        }

                        return pw.Column(
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(key!,
                                    style: pw.TextStyle(
                                        color: PdfColors.black,
                                        fontSize: 13,
                                        fontWeight: pw.FontWeight.bold
                                    ),),
                                  pw.Text(value,
                                    style: pw.TextStyle(
                                        color: PdfColors.black,
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold
                                    ),),
                                ],
                              ),
                              pw.SizedBox(height: 15)
                            ]
                        );
                      }
                      ),
                      pw.SizedBox(height: 80,),
                      // DashedLine(height: 1,),
                      pw.SizedBox(height: 10,),
                      pw.Text('Enjoy a better life with ElitePay. Book flight, book hotel, spend in foreign currencies, get '
                          'virtual foreign cards, pay all your bills',
                        style: pw.TextStyle(color: PdfColors.black, fontSize: 12),)
                    ]
                ),
              ];
            }
        )
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/nexpay_receipt_${DateTime.now().toLocal().toString().substring(0, 10)}.pdf');
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
          files:  [XFile(file.path)],
          title: 'NexPay Transaction Receipt',
          text: 'Get yours → ${AppLinkHandler.appLink}'
      ),
    );

  }
}