import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everywhere/components/dash_line.dart';
import 'package:everywhere/components/edit2.dart';
import 'package:everywhere/components/pin_entry.dart';
import 'package:everywhere/components/wallet_balance.dart';
import 'package:everywhere/models/service_model.dart';
import 'package:everywhere/screens/bottom_navigation/promotion.dart';
import 'package:everywhere/screens/core_services/airtime_screen.dart';
import 'package:everywhere/screens/bottom_navigation/profile_settings_screen.dart';
import 'package:everywhere/screens/core_services/cable_suscription.dart';
import 'package:everywhere/screens/core_services/data_screen.dart';
import 'package:everywhere/screens/core_services/electric_screen.dart';
import 'package:everywhere/screens/exams/jamb_screen.dart';
import 'package:everywhere/screens/exams/waec_screen.dart';
import 'package:everywhere/screens/core_services/rechargepins_screen.dart';
import 'package:everywhere/screens/notification_screen.dart';
import 'package:everywhere/screens/transaction_history_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import '../../components/account_information.dart';
import '../../components/formatters.dart';
import '../../components/promotion_screen.dart';
import '../../components/reusable_card.dart';
import '../../components/service_fraame.dart';
import '../../constraints/constants.dart';
import '../../models/notification_model.dart';
import '../../services/brain.dart';
import '../../services/purchase_service.dart';
import '../core_services/airtime_gift.dart';
import '../core_services/internet_services.dart';
import '../vendor_screen/vendor_engine_entry.dart';
import '../vendor_screen/vendor_engine_shell.dart';

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
    _checkBuild();
    // TODO: implement initState
    super.initState();
  }

  void _checkBuild() {
    final pov = Provider.of<Brain>(context, listen: false);
    if (pov.buildNumberFromFireStore > AppLinkHandler.buildNumber) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bool mandatory = pov.mandatory;
        List<String> newFeatures = pov.whatIsNew;
        showDialog(
          context: context,
          barrierDismissible: !mandatory,
          builder: (context) => AlertDialog(
            icon: Icon(Icons.upcoming_outlined, color: kErrorIconColor, size: 30,),
            actionsPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            title: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('NEW VERSION',  style: kAlertTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
                      SizedBox(width: 5,),
                      Text('(${pov.versionName})', style: kAlertTitle.copyWith(color: Colors.white70, fontSize: 13),)
                    ],
                  ),
                  SizedBox(height: 10,),
                  Text('An Update ${mandatory ? 'Required' : 'Recommended'}', style: kAlertTitle,),
                ],
              ),
            ),
            backgroundColor: kCardColor,
            alignment: Alignment.center,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('What\'s new?',
                      style: kAlertContent.copyWith(fontWeight: FontWeight.w900)),
                  SizedBox(height: 10),
                  if (newFeatures.isNotEmpty)
                    ...List.generate(newFeatures.length, (index) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('${index + 1}. ${newFeatures[index]}',
                            style: GoogleFonts.raleway(fontSize: 12,  ), textAlign: TextAlign.center,),
                        ),
                      );
                    }),
                ],
              ),
            ),
            actions: [
              mandatory ? Center(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 4,
                      padding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 30),
                      side: BorderSide(
                          color: kButtonColor
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                      ),
                    ),
                    onPressed: ()  async {
                      AppLinkHandler.openInPlayStore();
                    },
                    child: Text('Update on play store', style: GoogleFonts.raleway(color: Colors.white, fontSize: 13),)
                ),
              ) :
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kButtonColor,
                          elevation: 4,
                          padding: EdgeInsets.symmetric(vertical:
                          10, horizontal: 30),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Not now', style: GoogleFonts.raleway(color: Colors.black, fontSize: 11),)
                    ),
                    SizedBox(height: 10,),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 4,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          side: BorderSide(
                              color: kButtonColor
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        onPressed: ()  async {
                          AppLinkHandler.openInPlayStore();
                        },
                        child: Text('Update on Play Store',
                          style: GoogleFonts.raleway(color: Colors.white, fontSize: 13),)
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      });

    }
  }

  bool hasTouched = false;
  bool canPop = false;
  DateTime ? _lastBackTap;
  @override
  Widget build(BuildContext context) {

    super.build(context);

    // Number formatter
    String formatCurrency(double amount) {
      final formatter = NumberFormat('#,##0', 'en_US');
      return formatter.format(amount);
    }
    final pov = Provider.of<Brain>(context);

    List<ServiceModel> billServices = [
       ServiceModel(
           name: 'Airtime',
           icon: FontAwesomeIcons.mobileScreenButton,
           function: () {
             showModalBottomSheet(
                 isScrollControlled: true,
                 context: context,
                 builder: (context) => FractionallySizedBox(
                   heightFactor: 0.33,
                   child: Container(
                     padding: EdgeInsets.only(left: 15, right: 15),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('Choose Type', style: kTitle.copyWith(fontSize: 18)),
                         SizedBox(height: 5,),
                         Divider(),
                         SizedBox(height: 5,),
                         ...['Normal Airtime', 'Airtime Gift',].map((type) => GestureDetector(
                           onTap: () {
                             type == 'Normal Airtime' ? Navigator.push(context,
                                 MaterialPageRoute(builder: (context) => AirtimeScreen()))  : Navigator.push(context, MaterialPageRoute(
                                 builder: (context) => AirtimeGift())
                             );
                           },
                           child: ReusableCard2(
                             child: ListTile(
                               title: Text(type,
                                 style: GoogleFonts.averageSans(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),),
                               leading: Icon(
                                 type == 'Normal Airtime' ? Icons.business_center : Icons.card_giftcard, size: 20, color: Color(0xFF21D3ED),),),
                           ),
                         ), )
                       ],
                     ),
                   ),
                 )
             );
           }
       ),
      ServiceModel(
          name: 'Airtime Gift',
          icon:  Icons.card_giftcard,
          function: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => AirtimeGift())
            );
          },
        isNew: true,
      ),
      ServiceModel(
          name: 'Data',
          icon:  FontAwesomeIcons.wifi,
          function: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DataScreen()));
          }
      ),
      ServiceModel(
          name: 'Internet Services',
          icon:  FontAwesomeIcons.globe,
          function: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => InternetServicesScreen()));
          }
      ),
      ServiceModel(
          name: 'Cable',
          icon:  FontAwesomeIcons.tv,
          function: () {
            Navigator.pushNamed(context, '/cable'
                 );
          }
      ),
      ServiceModel(
          name: 'Electric Bills',
          icon:  FontAwesomeIcons.bolt,
          function: () {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => ElectricScreen()));
          }
      ),
      ServiceModel(
          name: 'International Airtime',
          icon:  FontAwesomeIcons.globeEurope,
          function: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => InternetServicesScreen()));
          }
      ),
      ServiceModel(
          name: 'Recharge Pins',
          icon:  FontAwesomeIcons.ticket,
          function: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => RechargePinsBusiness())
            );
          }
      ),
    ];

    List<ServiceModel> travelServices = [
      ServiceModel(
          name: 'Flights',
          icon:  FontAwesomeIcons.planeDeparture,
          function: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: Icon(Icons.sentiment_dissatisfied, color: kErrorIconColor, size: 30,),
                actionsPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                title: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('CURRENT VERSION:',  style: kAlertTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
                          SizedBox(width: 5,),
                          Text(AppLinkHandler.currentVersion, style: kAlertTitle.copyWith(color: Colors.white70, fontSize: 15),)
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor: kCardColor,
                alignment: Alignment.center,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('What\'s happening?',
                          style: kAlertContent.copyWith(fontWeight: FontWeight.w900)),
                      SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('This version does\'nt cover this service. Coming Soon, please bear with'
                              'the situation, our engineers are currently working on it, Stay tuned.',
                            style: GoogleFonts.raleway(fontSize: 12,  ), textAlign: TextAlign.center,
                            softWrap: true,),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 4,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          side: BorderSide(
                              color: kButtonColor
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        onPressed: ()  async {
                          Navigator.pop(context);
                        },
                        child: Text('Ok, I will be waiting', style: GoogleFonts.raleway(color: Colors.white, fontSize: 13),)
                    ),
                  )
                ],
              ),
            );
          }
      ),
      ServiceModel(
          name: 'Hotels',
          icon:  FontAwesomeIcons.hotel,
          function: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: Icon(Icons.sentiment_dissatisfied, color: kErrorIconColor, size: 30,),
                actionsPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                title: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('CURRENT VERSION:',  style: kAlertTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
                          SizedBox(width: 5,),
                          Text(AppLinkHandler.currentVersion, style: kAlertTitle.copyWith(color: Colors.white70, fontSize: 15),)
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor: kCardColor,
                alignment: Alignment.center,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('What\'s happening?',
                          style: kAlertContent.copyWith(fontWeight: FontWeight.w900)),
                      SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('This version does\'nt cover this service. Coming Soon, please bear with'
                              'the situation, our engineers are currently working on it, Stay tuned.',
                            style: GoogleFonts.raleway(fontSize: 12,  ), textAlign: TextAlign.center,
                            softWrap: true,),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 4,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          side: BorderSide(
                              color: kButtonColor
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        onPressed: ()  async {
                          Navigator.pop(context);
                        },
                        child: Text('Ok, I will be waiting', style: GoogleFonts.raleway(color: Colors.white, fontSize: 13),)
                    ),
                  )
                ],
              ),
            );
          }
      ),
      ServiceModel(
          name: 'Bus',
          icon:  FontAwesomeIcons.planeDeparture,
          function: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: Icon(Icons.sentiment_dissatisfied, color: kErrorIconColor, size: 30,),
                actionsPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                title: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('CURRENT VERSION:',  style: kAlertTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
                          SizedBox(width: 5,),
                          Text(AppLinkHandler.currentVersion, style: kAlertTitle.copyWith(color: Colors.white70, fontSize: 15),)
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor: kCardColor,
                alignment: Alignment.center,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('What\'s happening?',
                          style: kAlertContent.copyWith(fontWeight: FontWeight.w900)),
                      SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('This version does\'nt cover this service. Coming Soon, please bear with'
                              'the situation, our engineers are currently working on it, Stay tuned.',
                            style: GoogleFonts.raleway(fontSize: 12,  ), textAlign: TextAlign.center,
                            softWrap: true,),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 4,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          side: BorderSide(
                              color: kButtonColor
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        onPressed: ()  async {
                          Navigator.pop(context);
                        },
                        child: Text('Ok, I will be waiting', style: GoogleFonts.raleway(color: Colors.white, fontSize: 13),)
                    ),
                  )
                ],
              ),
            );
          }
      ),
      ServiceModel(
          name: 'Car rental',
          icon:  FontAwesomeIcons.hotel,
          function: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: Icon(Icons.sentiment_dissatisfied, color: kErrorIconColor, size: 30,),
                actionsPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                title: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('CURRENT VERSION:',  style: kAlertTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
                          SizedBox(width: 5,),
                          Text(AppLinkHandler.currentVersion, style: kAlertTitle.copyWith(color: Colors.white70, fontSize: 15),)
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor: kCardColor,
                alignment: Alignment.center,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('What\'s happening?',
                          style: kAlertContent.copyWith(fontWeight: FontWeight.w900)),
                      SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('This version does\'nt cover this service. Coming Soon, please bear with'
                              'the situation, our engineers are currently working on it, Stay tuned.',
                            style: GoogleFonts.raleway(fontSize: 12,  ), textAlign: TextAlign.center,
                            softWrap: true,),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 4,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          side: BorderSide(
                              color: kButtonColor
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        onPressed: ()  async {
                          Navigator.pop(context);
                        },
                        child: Text('Ok, I will be waiting', style: GoogleFonts.raleway(color: Colors.white, fontSize: 13),)
                    ),
                  )
                ],
              ),
            );
          }
      ),
    ];

    List<ServiceModel> essentialServices = [
      ServiceModel(
          name: 'Food',
          icon:  FontAwesomeIcons.bowlFood,
          function: () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => VendorEngineEntry()));
          }
      ),
      ServiceModel(
          name: 'Groceries',
          icon:  FontAwesomeIcons.hotel,
          function: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: Icon(Icons.sentiment_dissatisfied, color: kErrorIconColor, size: 30,),
                actionsPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                title: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('CURRENT VERSION:',  style: kAlertTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
                          SizedBox(width: 5,),
                          Text(AppLinkHandler.currentVersion, style: kAlertTitle.copyWith(color: Colors.white70, fontSize: 15),)
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor: kCardColor,
                alignment: Alignment.center,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('What\'s happening?',
                          style: kAlertContent.copyWith(fontWeight: FontWeight.w900)),
                      SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('This version does\'nt cover this service. Coming Soon, please bear with'
                              'the situation, our engineers are currently working on it, Stay tuned.',
                            style: GoogleFonts.raleway(fontSize: 12,  ), textAlign: TextAlign.center,
                            softWrap: true,),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 4,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          side: BorderSide(
                              color: kButtonColor
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        onPressed: ()  async {
                          Navigator.pop(context);
                        },
                        child: Text('Ok, I will be waiting', style: GoogleFonts.raleway(color: Colors.white, fontSize: 13),)
                    ),
                  )
                ],
              ),
            );
          }
      ),
      ServiceModel(
          name: 'Groceries',
          icon:  FontAwesomeIcons.planeDeparture,
          function: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: Icon(Icons.sentiment_dissatisfied, color: kErrorIconColor, size: 30,),
                actionsPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                title: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('CURRENT VERSION:',  style: kAlertTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
                          SizedBox(width: 5,),
                          Text(AppLinkHandler.currentVersion, style: kAlertTitle.copyWith(color: Colors.white70, fontSize: 15),)
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor: kCardColor,
                alignment: Alignment.center,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('What\'s happening?',
                          style: kAlertContent.copyWith(fontWeight: FontWeight.w900)),
                      SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('This version does\'nt cover this service. Coming Soon, please bear with'
                              'the situation, our engineers are currently working on it, Stay tuned.',
                            style: GoogleFonts.raleway(fontSize: 12,  ), textAlign: TextAlign.center,
                            softWrap: true,),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 4,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          side: BorderSide(
                              color: kButtonColor
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        onPressed: ()  async {
                          Navigator.pop(context);
                        },
                        child: Text('Ok, I will be waiting', style: GoogleFonts.raleway(color: Colors.white, fontSize: 13),)
                    ),
                  )
                ],
              ),
            );
          }
      ),
      ServiceModel(
          name: 'Drinks',
          icon:  FontAwesomeIcons.water,
          function: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: Icon(Icons.sentiment_dissatisfied, color: kErrorIconColor, size: 30,),
                actionsPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                title: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('CURRENT VERSION:',  style: kAlertTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
                          SizedBox(width: 5,),
                          Text(AppLinkHandler.currentVersion, style: kAlertTitle.copyWith(color: Colors.white70, fontSize: 15),)
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor: kCardColor,
                alignment: Alignment.center,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('What\'s happening?',
                          style: kAlertContent.copyWith(fontWeight: FontWeight.w900)),
                      SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('This version does\'nt cover this service. Coming Soon, please bear with'
                              'the situation, our engineers are currently working on it, Stay tuned.',
                            style: GoogleFonts.raleway(fontSize: 12,  ), textAlign: TextAlign.center,
                            softWrap: true,),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 4,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          side: BorderSide(
                              color: kButtonColor
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        onPressed: ()  async {
                          Navigator.pop(context);
                        },
                        child: Text('Ok, I will be waiting', style: GoogleFonts.raleway(color: Colors.white, fontSize: 13),)
                    ),
                  )
                ],
              ),
            );
          }
      ),
    ];

    List<ServiceModel> shoppingServices = [
      ServiceModel(
          name: 'Travel',
          icon:  FontAwesomeIcons.planeDeparture,
          function: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: Icon(Icons.sentiment_dissatisfied, color: kErrorIconColor, size: 30,),
                actionsPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                title: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('CURRENT VERSION:',  style: kAlertTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
                          SizedBox(width: 5,),
                          Text(AppLinkHandler.currentVersion, style: kAlertTitle.copyWith(color: Colors.white70, fontSize: 15),)
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor: kCardColor,
                alignment: Alignment.center,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('What\'s happening?',
                          style: kAlertContent.copyWith(fontWeight: FontWeight.w900)),
                      SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('This version does\'nt cover this service. Coming Soon, please bear with'
                              'the situation, our engineers are currently working on it, Stay tuned.',
                            style: GoogleFonts.raleway(fontSize: 12,  ), textAlign: TextAlign.center,
                            softWrap: true,),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 4,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          side: BorderSide(
                              color: kButtonColor
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        onPressed: ()  async {
                          Navigator.pop(context);
                        },
                        child: Text('Ok, I will be waiting', style: GoogleFonts.raleway(color: Colors.white, fontSize: 13),)
                    ),
                  )
                ],
              ),
            );
          }
      ),
      ServiceModel(
          name: 'Hotels',
          icon:  FontAwesomeIcons.hotel,
          function: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: Icon(Icons.sentiment_dissatisfied, color: kErrorIconColor, size: 30,),
                actionsPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                title: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('CURRENT VERSION:',  style: kAlertTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
                          SizedBox(width: 5,),
                          Text(AppLinkHandler.currentVersion, style: kAlertTitle.copyWith(color: Colors.white70, fontSize: 15),)
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor: kCardColor,
                alignment: Alignment.center,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('What\'s happening?',
                          style: kAlertContent.copyWith(fontWeight: FontWeight.w900)),
                      SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('This version does\'nt cover this service. Coming Soon, please bear with'
                              'the situation, our engineers are currently working on it, Stay tuned.',
                            style: GoogleFonts.raleway(fontSize: 12,  ), textAlign: TextAlign.center,
                            softWrap: true,),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 4,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          side: BorderSide(
                              color: kButtonColor
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        onPressed: ()  async {
                          Navigator.pop(context);
                        },
                        child: Text('Ok, I will be waiting', style: GoogleFonts.raleway(color: Colors.white, fontSize: 13),)
                    ),
                  )
                ],
              ),
            );
          }
      ),
      ServiceModel(
          name: 'Travel',
          icon:  FontAwesomeIcons.planeDeparture,
          function: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: Icon(Icons.sentiment_dissatisfied, color: kErrorIconColor, size: 30,),
                actionsPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                title: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('CURRENT VERSION:',  style: kAlertTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
                          SizedBox(width: 5,),
                          Text(AppLinkHandler.currentVersion, style: kAlertTitle.copyWith(color: Colors.white70, fontSize: 15),)
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor: kCardColor,
                alignment: Alignment.center,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('What\'s happening?',
                          style: kAlertContent.copyWith(fontWeight: FontWeight.w900)),
                      SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('This version does\'nt cover this service. Coming Soon, please bear with'
                              'the situation, our engineers are currently working on it, Stay tuned.',
                            style: GoogleFonts.raleway(fontSize: 12,  ), textAlign: TextAlign.center,
                            softWrap: true,),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 4,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          side: BorderSide(
                              color: kButtonColor
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        onPressed: ()  async {
                          Navigator.pop(context);
                        },
                        child: Text('Ok, I will be waiting', style: GoogleFonts.raleway(color: Colors.white, fontSize: 13),)
                    ),
                  )
                ],
              ),
            );
          }
      ),
      ServiceModel(
          name: 'Hotels',
          icon:  FontAwesomeIcons.hotel,
          function: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: Icon(Icons.sentiment_dissatisfied, color: kErrorIconColor, size: 30,),
                actionsPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                title: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('CURRENT VERSION:',  style: kAlertTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
                          SizedBox(width: 5,),
                          Text(AppLinkHandler.currentVersion, style: kAlertTitle.copyWith(color: Colors.white70, fontSize: 15),)
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor: kCardColor,
                alignment: Alignment.center,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('What\'s happening?',
                          style: kAlertContent.copyWith(fontWeight: FontWeight.w900)),
                      SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('This version does\'nt cover this service. Coming Soon, please bear with'
                              'the situation, our engineers are currently working on it, Stay tuned.',
                            style: GoogleFonts.raleway(fontSize: 12,  ), textAlign: TextAlign.center,
                            softWrap: true,),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 4,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          side: BorderSide(
                              color: kButtonColor
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        onPressed: ()  async {
                          Navigator.pop(context);
                        },
                        child: Text('Ok, I will be waiting', style: GoogleFonts.raleway(color: Colors.white, fontSize: 13),)
                    ),
                  )
                ],
              ),
            );
          }
      ),
    ];

    List<ServiceModel> examsServices = [
      ServiceModel(
          name: 'Travel',
          icon:  FontAwesomeIcons.planeDeparture,
          function: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: Icon(Icons.sentiment_dissatisfied, color: kErrorIconColor, size: 30,),
                actionsPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                title: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('CURRENT VERSION:',  style: kAlertTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
                          SizedBox(width: 5,),
                          Text(AppLinkHandler.currentVersion, style: kAlertTitle.copyWith(color: Colors.white70, fontSize: 15),)
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor: kCardColor,
                alignment: Alignment.center,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('What\'s happening?',
                          style: kAlertContent.copyWith(fontWeight: FontWeight.w900)),
                      SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('This version does\'nt cover this service. Coming Soon, please bear with'
                              'the situation, our engineers are currently working on it, Stay tuned.',
                            style: GoogleFonts.raleway(fontSize: 12,  ), textAlign: TextAlign.center,
                            softWrap: true,),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 4,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          side: BorderSide(
                              color: kButtonColor
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        onPressed: ()  async {
                          Navigator.pop(context);
                        },
                        child: Text('Ok, I will be waiting', style: GoogleFonts.raleway(color: Colors.white, fontSize: 13),)
                    ),
                  )
                ],
              ),
            );
          }
      ),
      ServiceModel(
          name: 'Hotels',
          icon:  FontAwesomeIcons.hotel,
          function: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: Icon(Icons.sentiment_dissatisfied, color: kErrorIconColor, size: 30,),
                actionsPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                title: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('CURRENT VERSION:',  style: kAlertTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
                          SizedBox(width: 5,),
                          Text(AppLinkHandler.currentVersion, style: kAlertTitle.copyWith(color: Colors.white70, fontSize: 15),)
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor: kCardColor,
                alignment: Alignment.center,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('What\'s happening?',
                          style: kAlertContent.copyWith(fontWeight: FontWeight.w900)),
                      SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('This version does\'nt cover this service. Coming Soon, please bear with'
                              'the situation, our engineers are currently working on it, Stay tuned.',
                            style: GoogleFonts.raleway(fontSize: 12,  ), textAlign: TextAlign.center,
                            softWrap: true,),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 4,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          side: BorderSide(
                              color: kButtonColor
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        onPressed: ()  async {
                          Navigator.pop(context);
                        },
                        child: Text('Ok, I will be waiting', style: GoogleFonts.raleway(color: Colors.white, fontSize: 13),)
                    ),
                  )
                ],
              ),
            );
          }
      ),
      ServiceModel(
          name: 'Travel',
          icon:  FontAwesomeIcons.planeDeparture,
          function: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: Icon(Icons.sentiment_dissatisfied, color: kErrorIconColor, size: 30,),
                actionsPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                title: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('CURRENT VERSION:',  style: kAlertTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
                          SizedBox(width: 5,),
                          Text(AppLinkHandler.currentVersion, style: kAlertTitle.copyWith(color: Colors.white70, fontSize: 15),)
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor: kCardColor,
                alignment: Alignment.center,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('What\'s happening?',
                          style: kAlertContent.copyWith(fontWeight: FontWeight.w900)),
                      SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('This version does\'nt cover this service. Coming Soon, please bear with'
                              'the situation, our engineers are currently working on it, Stay tuned.',
                            style: GoogleFonts.raleway(fontSize: 12,  ), textAlign: TextAlign.center,
                            softWrap: true,),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 4,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          side: BorderSide(
                              color: kButtonColor
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        onPressed: ()  async {
                          Navigator.pop(context);
                        },
                        child: Text('Ok, I will be waiting', style: GoogleFonts.raleway(color: Colors.white, fontSize: 13),)
                    ),
                  )
                ],
              ),
            );
          }
      ),
      ServiceModel(
          name: 'Hotels',
          icon:  FontAwesomeIcons.hotel,
          function: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: Icon(Icons.sentiment_dissatisfied, color: kErrorIconColor, size: 30,),
                actionsPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                title: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('CURRENT VERSION:',  style: kAlertTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
                          SizedBox(width: 5,),
                          Text(AppLinkHandler.currentVersion, style: kAlertTitle.copyWith(color: Colors.white70, fontSize: 15),)
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor: kCardColor,
                alignment: Alignment.center,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('What\'s happening?',
                          style: kAlertContent.copyWith(fontWeight: FontWeight.w900)),
                      SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('This version does\'nt cover this service. Coming Soon, please bear with'
                              'the situation, our engineers are currently working on it, Stay tuned.',
                            style: GoogleFonts.raleway(fontSize: 12,  ), textAlign: TextAlign.center,
                            softWrap: true,),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 4,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          side: BorderSide(
                              color: kButtonColor
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        onPressed: ()  async {
                          Navigator.pop(context);
                        },
                        child: Text('Ok, I will be waiting', style: GoogleFonts.raleway(color: Colors.white, fontSize: 13),)
                    ),
                  )
                ],
              ),
            );
          }
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        final now = DateTime.now();
        if (_lastBackTap == null || now.difference(_lastBackTap!) > Duration(seconds: 2)) {

          _lastBackTap = now;

          Fluttertoast.showToast(
              msg: 'Tap again to exit',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );


        }
        else {
          SystemNavigator.pop();
        }

      },
      child: Scaffold(
        backgroundColor: Color(0xFF0F172A),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF1E293B),
          title:  Text(
            'Services',
            style: kTopAppbars.copyWith(
                fontFamily:  'DejaVu Sans', fontSize: 23),
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                final Uri uri = Uri.parse('https://wa.me/message/BZ5RBPJYF7PHE1');
                if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                  throw Exception('Could not launch');
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text('Scan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(height: 2,),
                  Iconify(Ph.qr_code_duotone, size: 20, color: Colors.white,),
                ],
              ),
            ),
            SizedBox(width: 20,),
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
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder:
                    (context) => NotificationScreen()));
              },
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text('${Hive.box<AppNotification>('notifications').length}',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center ,),
                  ),
                  SizedBox(height: 2,),
                  Padding(
                      padding: EdgeInsetsGeometry.only(
                          bottom: 3, left: 15),
                      child: FaIcon(FontAwesomeIcons.bell, size: 20,)
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10,),
                    // Container(
                    //   width: double.infinity,
                    //   padding: EdgeInsets.only(bottom: 10, left: 15, right: 15, top: 10),
                    //   margin: EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 10),
                    //   decoration: BoxDecoration(
                    //     // color: Color(0xFF177E85),
                    //       color: Color(0xFF0F172A),
                    //       gradient: LinearGradient(
                    //           colors: [
                    //             Color(0xFF0F172A), Color(0xFF0D9488), Color(0xFF0F172A),],
                    //           begin: Alignment.topRight,
                    //           end: Alignment.bottomLeft,
                    //       ),
                    //       borderRadius: BorderRadius.circular(10),
                    //       boxShadow: [BoxShadow(color: Color(0xFF177E85).withOpacity(0.4),
                    //           blurRadius: 8, spreadRadius: 1, offset: Offset(0, 2))]
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: [
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           Row(
                    //             children: [
                    //               Row(
                    //                 children: [
                    //                   Icon(Icons.shield_moon_outlined, size: 18,),
                    //                   SizedBox(width: 2,),
                    //                   Text('Wallet Balance', style: kWalletStyle,),
                    //                 ],
                    //               ),
                    //               SizedBox(width: 5,),
                    //               GestureDetector(
                    //                   onTap: () {
                    //                     setState(() {
                    //                       hasTouched = !hasTouched;
                    //                     });
                    //                   },
                    //                   child: Icon(hasTouched ? FontAwesomeIcons.eyeSlash :
                    //                   FontAwesomeIcons.eye, size: 13, color: Colors.white70,)
                    //               )
                    //             ],
                    //           ),
                    //           Text('Reward Balance', style: kWalletStyle,),
                    //         ],
                    //       ),
                    //       StreamBuilder(
                    //           stream: FirebaseFirestore
                    //               .instance.collection('users')
                    //               .doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
                    //           builder: (context, snapshot) {
                    //             final data = snapshot.data;
                    //             if (!snapshot.hasData) {
                    //               return CircularProgressIndicator();
                    //             }
                    //             if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                    //               return Row(
                    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //                 children: [
                    //                   Text('An error occurred or network')
                    //                 ],
                    //               );
                    //             }
                    //             if (!snapshot.data!.exists) {
                    //               return CircularProgressIndicator();
                    //             }
                    //             return Row(
                    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //               children: [
                    //                 hasTouched ? Text('******', style: kMoneyStyle,) :  Row(
                    //                   children: [
                    //                     Text(kNaira, style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),),
                    //                     SizedBox(width: 3,),
                    //                     BalanceText(data!['balance'].toDouble(), 30, 15)
                    //                   ],
                    //                 ),
                    //                 hasTouched ? Text('******', style: kMoneyStyle,) :  Row(
                    //                   children: [
                    //                     Text(kNaira, style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),),
                    //                     SizedBox(width: 3,),
                    //                     BalanceText(double.parse(pov.accountReward), 20, 10)
                    //                   ],
                    //                 ),
                    //               ],
                    //             );
                    //           }
                    //       ),
                    //       Container(
                    //           width: double.infinity,
                    //           padding: EdgeInsets.only(bottom: 10, left: 15, right: 15, top: 10),
                    //           margin: EdgeInsets.only(left: 0, right: 0, bottom: 4, top: 5),
                    //           decoration: BoxDecoration(
                    //             // color: Color(0xFF0F172A),
                    //               color: Color(0xFF177E85),
                    //               borderRadius: BorderRadius.circular(10),
                    //               boxShadow: [BoxShadow(color: Color(0xFF0F172A).withOpacity(0.6),
                    //                   blurRadius: 8, spreadRadius: 1, offset: Offset(0, 2))]
                    //           ),
                    //           child: GestureDetector(
                    //             onTap: ()  {
                    //               showModalBottomSheet(
                    //                 context: context, builder: (context) => FractionallySizedBox(
                    //                 heightFactor: 0.4,
                    //                 child: AccountInformation(),
                    //               ),
                    //                 isScrollControlled: true,
                    //                 showDragHandle: true,
                    //                 // backgroundColor: Color(0xFF333333),
                    //               );
                    //             },
                    //             child: Row(
                    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //               children: [
                    //                 Text('Add Funds', style: kExpenseStyle,),
                    //                 Icon(
                    //                   FontAwesomeIcons.plusCircle,
                    //                 )
                    //               ],
                    //             ),
                    //           )
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // PromoCarousel(),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 15),
                    //   child: Text('Transfer', style: GoogleFonts.poppins(
                    //       fontSize: 17, fontWeight: FontWeight.w900),),
                    // ),
                    Container(
                        height: 100,
                        width: double.infinity,
                        margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFF1E293B),
                        ),
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ServiceFrame(
                              title: 'To NexPay',
                              icon: FontAwesomeIcons.bank,
                              onTap: () {},
                              isNew: false,
                              titleFont: 12,
                            ),
                            ServiceFrame(
                              title: 'To Bank',
                              icon: FontAwesomeIcons.bank,
                              onTap: () {},
                              isNew: false,
                              titleFont: 12,

                            ),
                            ServiceFrame(
                              title: 'Bank Card',
                              icon: FontAwesomeIcons.creditCard,
                              onTap: () {},
                              isNew: false,
                              titleFont: 12,
                            ),
                            ServiceFrame(
                              title: 'Withdraw',
                              icon: FontAwesomeIcons.moneyBill,
                              onTap: () {},
                              isNew: false,
                              titleFont: 12,

                            ),
                          ],
                        )
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 15),
                    //   child: Text('Insights', style: GoogleFonts.poppins(
                    //       fontSize: 17, fontWeight: FontWeight.w900),),
                    // ),
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
                                Text('This Month, ${MyFormatManager.formatMyDate(DateTime.now(), 'MMM d')}',
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w900, fontSize: 12),),
                                GestureDetector(
                                    onTap: ()  {
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
                                            style: GoogleFonts.roboto(color: Colors.white,
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
                                    // Text('Total Money In:',
                                    //   style: GoogleFonts.roboto(
                                    //       fontWeight: FontWeight.w700,
                                    //       color: Colors.white54, fontSize: 12),),
                                    Text('Total money Spent:',
                                        style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w700, color: Colors.white54, fontSize: 12))
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row(
                                    //   children: [
                                    //     Text(kNaira, style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),),
                                    //     SizedBox(width: 3,),
                                    //     BalanceText(0, 16, 8)
                                    //   ],
                                    // ),
                                    Row(
                                      children: [
                                        Text(kNaira, style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),),
                                        SizedBox(width: 3,),
                                        BalanceText(pov.totalMonthlySpent, 16, 8)
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        )),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 15),
                    //   child: Text('Services',
                    //     style: GoogleFonts.poppins(fontSize: 17,
                    //         fontWeight: FontWeight.w900),
                    //   ),
                    // ),
                    Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFF1E293B),
                        ),
                        child:  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20, top: 10),
                              child: Text('Bills', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),),
                            ),
                            GridView.builder(
                                padding: EdgeInsets.zero,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 0,
                                  mainAxisSpacing: 1,
                                ),
                                itemCount: billServices.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final service = billServices[index];
                                  return ServiceFrame(
                                      title: service.name,
                                      icon: service.icon,
                                      onTap: service.function,
                                    isNew: service.isNew ?? false,
                                    // backgroundColor: Colors.white,
                                    // iconColor: Color(0xFF177E85),
                                  );
                                }
                            ),
                          ],
                        )
                    ),
                    SizedBox(height: 10,),
                    Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFF1E293B),
                        ),
                        child:  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20, top: 10),
                              child: Text('Travel & Hotels', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),),
                            ),
                            GridView.builder(
                                padding: EdgeInsets.zero,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 0,
                                  mainAxisSpacing: 1,
                                ),
                                itemCount: travelServices.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final service = travelServices[index];
                                  return ServiceFrame(
                                    title: service.name,
                                    icon: service.icon,
                                    onTap: service.function,
                                    isNew: service.isNew ?? false,
                                  );
                                }
                            ),
                          ],
                        )
                    ),
                    SizedBox(height: 10,),
                    Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFF1E293B),
                        ),
                        child:  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20, top: 10),
                              child: Text('Essentials', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),),
                            ),
                            GridView.builder(
                                padding: EdgeInsets.zero,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 0,
                                  mainAxisSpacing: 1,
                                ),
                                itemCount: essentialServices.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final service = essentialServices [index];
                                  return ServiceFrame(
                                    title: service.name,
                                    icon: service.icon,
                                    onTap: service.function,
                                    isNew: service.isNew ?? false,
                                  );
                                }
                            ),
                          ],
                        )
                    ),
                    SizedBox(height: 10,),
                    Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFF1E293B),
                        ),
                        child:  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20, top: 10),
                              child: Text('Shopping', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),),
                            ),
                            GridView.builder(
                                padding: EdgeInsets.zero,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 0,
                                  mainAxisSpacing: 1,
                                ),
                                itemCount: shoppingServices.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final service = billServices[index];
                                  return ServiceFrame(
                                    title: service.name,
                                    icon: service.icon,
                                    onTap: service.function,
                                    isNew: service.isNew ?? false,
                                  );
                                }
                            ),
                          ],
                        )
                    ),
                    SizedBox(height: 10,),
                    PromoCarousel()
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
