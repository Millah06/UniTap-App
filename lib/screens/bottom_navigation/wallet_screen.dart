import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everywhere/components/flush_bar_message.dart';
import 'package:everywhere/components/wallet_balance.dart';
import 'package:everywhere/constraints/constants.dart';
import 'package:everywhere/screens/airtime_screen.dart';
import 'package:everywhere/screens/cable_suscription.dart';
import 'package:everywhere/screens/electric_screen.dart';
import 'package:everywhere/screens/rechargepins_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../components/account_information.dart';
import '../../components/recent_frame.dart';
import '../../components/reusable_card.dart';
import '../../components/service_fraame.dart';
import '../../components/view_receipt.dart';
import '../../services/brain.dart';
import '../data_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  static String id = 'wallet';

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {

  bool hasTouched = false;

  Future<void> _generateAndShareImage() async {

  }

  @override
  Widget build(BuildContext context) {
    final pov = Provider.of<Brain>(context);
    return Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 330,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black38, Color(0xFF177E85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      // image: DecorationImage(fit: BoxFit.cover,
                      //     image: AssetImage('images/wallet.jpg')),
                    color: kButtonColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30)
                      )
                  ),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                            margin: EdgeInsetsGeometry.only(left: 12),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              // color: Colors.white,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.shield_moon_outlined),
                                          Text('Total Assets', style:
                                          TextStyle(color: Colors.white70,
                                              fontWeight: FontWeight.w900,
                                              fontFamily: 'DejaVu Sans'),),
                                          SizedBox(width: 5,),
                                          GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  hasTouched = !hasTouched;
                                                });
                                              },
                                              child: Icon(hasTouched ? FontAwesomeIcons.eyeSlash :
                                              FontAwesomeIcons.eye, size: 13, color: Colors.white70,)
                                          )

                                        ],
                                      ),
                                      Row(
                                        textBaseline: TextBaseline.alphabetic,
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        children: [
                                          Text(kNaira, style:
                                          kMoneyStyle.copyWith(fontFamily: 'DejaVu Sans', fontSize: 18),),
                                          SizedBox(width: 2,),
                                          BalanceText(20000, 35, 20),
                                        ],
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(1.5),
                                          decoration: BoxDecoration(
                                              color: Colors.pink,
                                              borderRadius: BorderRadius.circular(5)
                                          ),
                                          child: Text('HELP',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),),
                                        ),
                                        SizedBox(height: 2,),
                                        FaIcon(FontAwesomeIcons.headset, size: 30,),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ),
                        SizedBox(height: 10,),
                        AccountInformation()
                      ],
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 280, left: 20, right: 20),
                    child: ReusableCard(
                      child: SizedBox(
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ServiceFrame(
                              title: 'Buy Data',
                              icon: Icon(Icons.wifi),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => DataScreen())
                                );
                              },
                            ),
                            ServiceFrame(
                              title: 'Buy Airtime',
                              icon: Icon(Icons.phone),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => AirtimeScreen())
                                );
                              },
                            ),
                            ServiceFrame(
                              title: 'More',
                              icon: Icon(Icons.more_horiz),
                              onTap: () {
                                showModalBottomSheet(
                                    context: context, builder: (context) =>
                                    FractionallySizedBox(
                                      heightFactor: 1,
                                      child: Container(
                                        padding: EdgeInsets.only(left: 15, right: 15),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Other Services', style: kTitle.copyWith(fontSize: 18)),
                                            SizedBox(height: 5,),
                                            Divider(),
                                            SizedBox(height: 5,),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(context, MaterialPageRoute(
                                                    builder: (context) => ElectricScreen())
                                                );
                                              },
                                              child: ReusableCard2(
                                                child: ListTile(
                                                  title: Text('Electric Bill',
                                                    style: kTitle.copyWith(fontSize: 15),),
                                                  leading: Icon(
                                                    Icons.bolt, size: 20, color: Color(0xFF21D3ED),),),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(context, MaterialPageRoute(
                                                    builder: (context) => CableSubscription())
                                                );
                                              },
                                              child: ReusableCard2(
                                                child: ListTile(
                                                  title: Text('Cable Subscription', style: kTitle.copyWith(fontSize: 15),),
                                                  leading: Icon(
                                                    Icons.cable, size: 20, color: Color(0xFF21D3ED),),),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {},
                                              child: ReusableCard2(
                                                child: ListTile(
                                                  title: Text(
                                                    'Education Pins', style: kTitle.copyWith(fontSize: 15),),
                                                  leading: Icon(
                                                    Icons.cast_for_education, size: 20, color: Color(0xFF21D3ED),),),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(context, MaterialPageRoute(
                                                    builder: (context) => RechargePinsScreen())
                                                );
                                              },
                                              child: ReusableCard2(
                                                child: ListTile(
                                                  title: Text(
                                                    'Recharge Pins',
                                                    style: kTitle.copyWith(fontSize: 15),),
                                                  leading: Icon(
                                                    Icons.receipt, size: 20, color: Color(0xFF21D3ED),),),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    )
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
              child: Text('Recent Transactions',  style:
              GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900),),
            ),
            Expanded(
              child: pov.transactions.isEmpty ?
              Center(child: Text('No Transactions yet', style: GoogleFonts.inter(),),) :
              ListView.builder(
                padding: EdgeInsets.only(left: 15, right: 15),
                itemBuilder: (BuildContext context, int index) {
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
            )
          ],
        )
    );
  }
}
