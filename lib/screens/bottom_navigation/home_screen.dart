import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everywhere/components/dash_line.dart';
import 'package:everywhere/components/pin_entry.dart';
import 'package:everywhere/components/wallet_balance.dart';
import 'package:everywhere/models/service_model.dart';
import 'package:everywhere/screens/airtime_screen.dart';
import 'package:everywhere/screens/bottom_navigation/profile_settings_screen.dart';
import 'package:everywhere/screens/cable_suscription.dart';
import 'package:everywhere/screens/data_screen.dart';
import 'package:everywhere/screens/electric_screen.dart';
import 'package:everywhere/screens/exams/jamb_screen.dart';
import 'package:everywhere/screens/exams/neco_screen.dart';
import 'package:everywhere/screens/exams/waec_screen.dart';
import 'package:everywhere/screens/rechargepins_screen.dart';
import 'package:everywhere/screens/transaction_history_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/account_information.dart';
import '../../components/promotion_screen.dart';
import '../../components/reusable_card.dart';
import '../../components/service_fraame.dart';
import '../../constraints/constants.dart';
import '../../services/brain.dart';
import '../../services/purchase_service.dart';
import '../internet_services.dart';

class HomeScreen extends StatefulWidget {

  static String id = 'home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Flushbar(
        title: 'Success',
        message: 'Logged in successfully!',
        borderRadius: BorderRadius.circular(12),
        duration: Duration(seconds: 1),
        icon: Icon(Icons.check_circle, color: Colors.green,),
        backgroundColor: kErrorBackground,
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    });
    // TODO: implement initState
    super.initState();
  }

  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.paused) {
  //     _controller.stop();
  //   } else if (state == AppLifecycleState.resumed) {
  //     _controller.repeat(reverse: true);
  //   }
  // }
  //
  // @override
  // void dispose() {
  //   _controller.dispose();
  //   // TODO: implement dispose
  //   super.dispose();
  // }

  bool hasTouched = false;
  @override
  Widget build(BuildContext context) {

    super.build(context);

    // Number formatter
    String formatCurrency(double amount) {
      final formatter = NumberFormat('#,##0', 'en_US');
      return formatter.format(amount);
    }
    final pov = Provider.of<Brain>(context);

    List<ServiceModel> services = [
       ServiceModel(
           name: 'Airtime',
           icon: Icon(
             FontAwesomeIcons.mobileScreenButton,
             size: kServiceIconSize, color: Colors.white,),
           function: () {
             Navigator.push(context,
                 MaterialPageRoute(builder: (context) => AirtimeScreen()));
           }
       ),
      ServiceModel(
          name: 'Data',
          icon: Icon(FontAwesomeIcons.wifi, size: kServiceIconSize, color: Colors.white),
          function: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DataScreen()));
          }
      ),
      ServiceModel(
          name: 'Internet Services',
          icon: Icon(FontAwesomeIcons.globe, size: kServiceIconSize,color: Colors.white),
          function: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => InternetServicesScreen()));
          }
      ),
      ServiceModel(
          name: 'Cable',
          icon: Icon(FontAwesomeIcons.tv, size: kServiceIconSize, color: Colors.white),
          function: () {
            Navigator.pushNamed(context, '/cable'
                 );
          }
      ),
      ServiceModel(
          name: 'Electric Bills',
          icon: Icon(FontAwesomeIcons.bolt, size: kServiceIconSize, color: Colors.white),
          function: () {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => ElectricScreen()));
          }
      ),
      ServiceModel(
          name: 'Exams',
          icon: Icon(FontAwesomeIcons.graduationCap, size: kServiceIconSize, color: Colors.white),
          function: () {
            showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) => FractionallySizedBox(
                  heightFactor: 0.6,
                  child: Container(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Exam Services', style: kTitle.copyWith(fontSize: 18)),
                        SizedBox(height: 5,),
                        Divider(),
                        SizedBox(height: 5,),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => WaecServices())
                            );
                          },
                          child: ReusableCard2(
                            child: ListTile(
                              title: Text('WAEC',
                                style: kTitle.copyWith(fontSize: 15),),
                              leading: Icon(
                                Icons.bolt, size: 20, color: Color(0xFF21D3ED),),),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => JambServices())
                            );
                          },
                          child: ReusableCard2(
                            child: ListTile(
                              title: Text('JAMB', style: kTitle.copyWith(fontSize: 15),),
                              leading: Icon(
                                Icons.cable, size: 20, color: Color(0xFF21D3ED),),),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NecoServices()));
                          },
                          child: ReusableCard2(
                            child: ListTile(
                              title: Text(
                                'NECO', style: kTitle.copyWith(fontSize: 15),),
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
                                'NABTEB',
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
          }
      ),
      ServiceModel(
          name: 'Recharge Pins',
          icon: Icon(FontAwesomeIcons.ticket, size: kServiceIconSize, color: Colors.white),
          function: () {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => RechargePinsScreen()));
          }
      ),
      ServiceModel(
          name: 'Hotels & Travel',
          icon: Icon(FontAwesomeIcons.planeDeparture, size: kServiceIconSize, color: Colors.white),
          function: () {}
      ),
      ServiceModel(
          name: 'More',
          icon: Icon(FontAwesomeIcons.ellipsis, size: kServiceIconSize, color: Colors.white),
          function: () {}
      )
    ];

    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(top: 25, left: 8, bottom: 0),
            color: Color(0xFF177E85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.all(10),
                    child:
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder:  (context)=> ProfileSettingsScreen()));
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color:  Color(0xFFE3E3E3),
                                    width: 1
                                )
                            ),
                            child: ClipOval(
                                child:   pov.isLoading ? CircularProgressIndicator() :
                                Image.file(File(pov.image), fit: BoxFit.cover,)
                            ),
                          ),
                        ),
                      ],
                    )
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('EveryWhere', style: kTopAppbars.copyWith(
                                fontFamily:  'DejaVu Sans'), ),
                            // Text('Welcome ${pov.user}', style: kWelcomeStyle,),
                            Text('Welcome back ${pov.user}!', style: kWelcomeStyle,)
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.ideographic,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final Uri uri = Uri.parse('https://wa.me/message/BZ5RBPJYF7PHE1');
                                if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                  throw Exception('Could not launch');
                                }
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(1.5),
                                    decoration: BoxDecoration(
                                        color: Colors.pink,
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Text('HELP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),),
                                  ),
                                  SizedBox(height: 2,),
                                  FaIcon(FontAwesomeIcons.headset, size: 20,),
                                ],
                              ),
                            ),
                            SizedBox(width: 15,),
                            Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                      color: Colors.pink,
                                      borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Text('18',
                                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center ,),
                                ),
                                SizedBox(height: 2,),
                                Padding(
                                  padding: EdgeInsetsGeometry.only(
                                      bottom: 3, left: 15),
                                    child: FaIcon(FontAwesomeIcons.bell, size: 20,)
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(bottom: 10, left: 15, right: 15, top: 10),
                    margin: EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 10),
                    decoration: BoxDecoration(
                      // color: Color(0xFF177E85),
                        color: Color(0xFF0F172A),
                        gradient: LinearGradient(
                            colors: [
                              Color(0xFF0F172A), Color(0xFF0D9488), Color(0xFF0F172A),],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Color(0xFF177E85).withOpacity(0.4),
                            blurRadius: 8, spreadRadius: 1, offset: Offset(0, 2))]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.shield_moon_outlined, size: 18,),
                                    SizedBox(width: 2,),
                                    Text('Wallet Balance', style: kWalletStyle,),
                                  ],
                                ),
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
                            Text('Reward Balance', style: kWalletStyle,),
                          ],
                        ),
                        StreamBuilder(
                            stream: FirebaseFirestore
                                .instance.collection('users')
                                .doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
                            builder: (context, snapshot) {
                              final data = snapshot.data;
                              if (!snapshot.hasData) {
                                return CircularProgressIndicator();
                              }
                              if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('An error occurred or network')
                                  ],
                                );
                              }
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  hasTouched ? Text('******', style: kMoneyStyle,) :  Row(
                                    children: [
                                      Text(kNaira, style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),),
                                      SizedBox(width: 3,),
                                      BalanceText(data!['balance'].toDouble(), 30, 15)
                                    ],
                                  ),
                                  hasTouched ? Text('******', style: kMoneyStyle,) :  Row(
                                    children: [
                                      Text(kNaira, style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),),
                                      SizedBox(width: 3,),
                                      BalanceText(56096.67, 20, 10)
                                    ],
                                  ),
                                ],
                              );
                            }
                        ),
                        Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(bottom: 10, left: 15, right: 15, top: 10),
                            margin: EdgeInsets.only(left: 0, right: 0, bottom: 4, top: 5),
                            decoration: BoxDecoration(
                              // color: Color(0xFF0F172A),
                                color: Color(0xFF177E85),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [BoxShadow(color: Color(0xFF0F172A).withOpacity(0.6),
                                    blurRadius: 8, spreadRadius: 1, offset: Offset(0, 2))]
                            ),
                            child: GestureDetector(
                              onTap: ()  {
                                showModalBottomSheet(
                                  context: context, builder: (context) => FractionallySizedBox(
                                  heightFactor: 0.4,
                                  child: AccountInformation(),
                                ),
                                  isScrollControlled: true,
                                  showDragHandle: true,
                                  // backgroundColor: Color(0xFF333333),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Add Funds', style: kExpenseStyle,),
                                  Icon(
                                    FontAwesomeIcons.plusCircle,
                                  )
                                ],
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                  PromoCarousel(),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text('Insights', style: GoogleFonts.poppins(
                        fontSize: 17, fontWeight: FontWeight.w900),),
                  ),
                  Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(bottom: 10, left: 15, right: 15, top: 10),
                      margin: EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFF1E293B),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('This Month, ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),),
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => TransactionHistoryScreen()));
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF0F172A),
                                      border: Border.all(color: Colors.white54)
                                    ),
                                    child: Row(
                                      children: [
                                        Text('Transaction History',
                                          style: TextStyle(color: Colors.white,
                                              fontSize: 11),),
                                        SizedBox(width: 5,),
                                        Icon(Icons.arrow_forward_ios_sharp, size: 10, color: Colors.white,)
                                      ],
                                    ),
                                  )
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          DashedLine(),
                          SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Money In:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700, color: Colors.white54, fontSize: 12),),
                                  Text('Total money Spent:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700, color: Colors.white54, fontSize: 12))
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(kNaira, style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),),
                                      SizedBox(width: 3,),
                                      BalanceText(56096.67, 16, 8)
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(kNaira, style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),),
                                      SizedBox(width: 3,),
                                      BalanceText(47096.67, 16, 8)
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text('Services',
                      style: GoogleFonts.poppins(fontSize: 17,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  Container(
                      height: 305,
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFF1E293B),
                      ),
                      child:  GridView.builder(
                          padding: EdgeInsets.zero,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.9,
                            crossAxisSpacing: 30,
                            mainAxisSpacing: 0,
                          ),
                          itemCount: services.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final service = services[index];
                            return ServiceFrame(
                                title: service.name,
                                icon: service.icon,
                                onTap: service.function
                            );
                          }
                      )
                  ),
                  PromoCarousel()
                  // SliverToBoxAdapter(
                  //   child: SizedBox(
                  //     height: 200,
                  //     child: PromoCarousel(
                  //     ),
                  //   ),
                  // ),

                  // SliverToBoxAdapter(
                  //     child: SizedBox(
                  //       height: 200,
                  //       child: PromoCarousel(
                  //
                  //       ),
                  //     ),
                  // )
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
