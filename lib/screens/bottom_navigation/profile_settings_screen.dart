import 'package:everywhere/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/account_information.dart';
import '../../components/reusable_card.dart';
import '../../constraints/constants.dart';
import '../../services/brain.dart';
import '../privacy_policy.dart';


class ProfileSettingsScreen  extends StatefulWidget {
  const ProfileSettingsScreen ({super.key});
  static String id = 'account';

  @override
  State<ProfileSettingsScreen > createState() => _ToolScreenState();
}

class _ToolScreenState extends State<ProfileSettingsScreen > {

  @override
  Widget build(BuildContext context) {
    // Provider.of<Brain>(context);
    final pov = Provider.of<Brain>(context);

    void launchEmail(String subject) async {
      final Uri emailLaunchUri = Uri(
        scheme : 'mailto',
        path: 'team.smartspend@gmail.com',
        queryParameters: {
          'Subject' : subject,
        },
      );
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      }
      else {
        throw 'Could not launch email app';
      }
    }

    String formatCurrency(double amount) {
      final formatter = NumberFormat('#,##0', 'en_US');
      return formatter.format(amount);
    }

    return  Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Column(
        children: [
          Stack(
            children: [
              Container(

                margin: EdgeInsets.all(0),
                padding: EdgeInsets.only(top: 0,  bottom: 20),
                height: 200,
                decoration: BoxDecoration(
                    image: DecorationImage(fit: BoxFit.cover,
                        image: AssetImage('images/wallet.jpg')),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30)
                    )
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 100),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: 20,),
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color:  Colors.white,
                                    width: 3
                                )
                            ),
                            child: ClipOval(
                              child: Image.file(File(pov.image), fit: BoxFit.cover,)
                              // child: File(pov2.image) != null? Image.file(File(pov2.image), fit: BoxFit.cover,) :
                              // Icon(Icons.person, size: 70, color: Color(0xFF00B875),),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 110, left: 80),
                            child: GestureDetector(
                              onTap: pov.updateImage,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFF177E85),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(FontAwesomeIcons.plusCircle,
                                  size: 22, color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),

                    ],
                  ),
                ),
              )
            ]
          ),
          // SizedBox(height: 20,),
          Expanded(
            child: Container(
              padding: EdgeInsets.only( left: 0, right: 0,),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ReusableCard(
                    child: Column(
                      children: [
                        // add name, username, subscription, logout
                        Text('Account', style: kAccountHeaderStyle,),
                        Divider(color: Colors.white54, indent: 35, endIndent: 35,),
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // showModalBottomSheet(
                                  //   context: context, builder: (context) => EditBottomSheet(theThing: 'Name',),
                                  //   isScrollControlled: true,
                                  // );
                                },
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Name: Abdullahi Aliyu', style: kSetting),
                                  // title: Text('Name: ${pov2.nam}', style: kSetting,),
                                  trailing: IconButton(
                                      style: IconButton.styleFrom(
                                          backgroundColor: Color(0xFF177E85)
                                      ),
                                      onPressed: () {
                                        // showModalBottomSheet(
                                        //   context: context, builder: (context) => EditBottomSheet(theThing: 'Name',),
                                        //   isScrollControlled: true,
                                        // );
                                      },
                                      icon: Icon(Icons.edit, color: Colors.white,)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // showModalBottomSheet(
                                  //   context: context, builder: (context) => EditBottomSheet(theThing: 'Name',),
                                  //   isScrollControlled: true,
                                  // );
                                },
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Username: ${pov.userName}', style: kSetting),
                                  // title: Text('Name: ${pov2.nam}', style: kSetting,),
                                  trailing: IconButton(
                                      style: IconButton.styleFrom(
                                          backgroundColor: Color(0xFF177E85)
                                      ),
                                      onPressed: () {
                                        // showModalBottomSheet(
                                        //   context: context, builder: (context) => EditBottomSheet(theThing: 'Name',),
                                        //   isScrollControlled: true,
                                        // );
                                      },
                                      icon: Icon(Icons.edit, color: Colors.white,)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context, builder: (context) =>
                                      FractionallySizedBox(
                                    heightFactor: 0.4,
                                    child: AccountInformation(),
                                  ),
                                    isScrollControlled: true,
                                    showDragHandle: true,
                                    // backgroundColor: Color(0xFF333333),
                                  );
                                },
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Wallet Balance: \$30,009', style: kSetting,),
                                  trailing: IconButton(
                                    style: IconButton.styleFrom(backgroundColor:
                                    Color(0xFF177E85)),
                                    onPressed: () {
                                      // showModalBottomSheet(
                                      //   context: context, builder: (context) => EditBottomSheet(theThing: 'Income',),
                                      //   isScrollControlled: true,
                                      // );
                                    },
                                    icon: Icon(
                                      FontAwesomeIcons.plusCircle,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text('Logout/ Switch Account', style: kSetting,),
                                trailing: IconButton(
                                  color: Colors.red,
                                  style: IconButton.styleFrom(
                                      backgroundColor:Color(0xFF177E85)),
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Logout Confirmation', style:
                                        GoogleFonts.poppins(fontSize: 17,
                                            fontWeight: FontWeight.w900, color: Colors.white),),
                                        backgroundColor: kCardColor,
                                        shape:
                                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        content: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Are you sure, you want logout?',
                                                  style:
                                                  GoogleFonts.inter(fontSize: 15,
                                                      fontWeight: FontWeight.bold)),
                                              SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                  child: Text('No', style: TextStyle(color: Colors.white),)
                                              ),
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
                                                    Navigator.pop(context);
                                                    final prefs = await SharedPreferences.getInstance();
                                                    await FirebaseAuth.instance.signOut();
                                                    await prefs.setBool('isSetupDone', false);
                                                    Navigator.pushAndRemoveUntil(
                                                      context, MaterialPageRoute(builder: (_) => WelcomeScreen()),
                                                          (route) => false,);
                                                  },
                                                  child: Text('Yes', style: TextStyle(color: Colors.white),)
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    );

                                  },
                                  icon: Icon(Icons.logout),),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  ReusableCard(
                    child: Column(
                      children: [
                        // add notification, Language and region, currency preferences
                        Text('Settings', style: kAccountHeaderStyle,),
                        Divider(color: Colors.white54, indent: 35, endIndent: 35,),
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text('Notifications', style: kSetting,),
                                trailing: Switch(value: true, onChanged: (value) {
                                  value = true;
                                }),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  ReusableCard(
                    child: Column(
                      children: [
                        // Contact us, Feed back
                        Text('Help', style: kAccountHeaderStyle,),
                        Divider(color: Colors.white54, indent: 35, endIndent: 35,),
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {launchEmail('SmartSpendSupportCenter');},
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Contact us', style: kSetting,),
                                  trailing:  IconButton(
                                    style: IconButton.styleFrom(
                                        backgroundColor: Color(0xFF177E85)),
                                    onPressed: () {launchEmail('SmartSpendSupportCenter');},
                                    icon: Icon(Icons.mail, color: Colors.white,),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  launchEmail('SmartSpendFeedBack');
                                },
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Feed Back', style: kSetting,),
                                  trailing: IconButton(
                                      style: IconButton.styleFrom(
                                          backgroundColor: Color(0xFF177E85)),
                                      onPressed:  () {
                                        launchEmail('SmartSpendFeedBack');
                                      },
                                      icon: Icon(Icons.feedback, color: Colors.white,)),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  ReusableCard(
                      child: Column(
                        children: [
                          // Add app version, privacy polycy
                          Text('About', style: kAccountHeaderStyle,),
                          Divider(color: Colors.white54, indent: 35, endIndent: 35,),
                          Padding(
                            padding: EdgeInsets.only(left: 0),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('App version', style: kSetting,),
                                  trailing: Text('3.0.0'),
                                ),
                                GestureDetector(
                                  onTap:  () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                        PrivacyPolicyPage()));
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text('Privacy Policy', style: kSetting,),
                                    trailing: IconButton(
                                        style: IconButton.styleFrom(
                                            backgroundColor: Color(0xFF177E85)),
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                              PrivacyPolicyPage()));
                                        },
                                        icon: Icon(Icons.chevron_right_sharp, color: Colors.white,)),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}