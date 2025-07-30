import 'package:everywhere/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.add, size: 22, color: Color(0xFF00B875),),
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
                                          backgroundColor: Colors.white
                                      ),
                                      onPressed: () {
                                        // showModalBottomSheet(
                                        //   context: context, builder: (context) => EditBottomSheet(theThing: 'Name',),
                                        //   isScrollControlled: true,
                                        // );
                                      },
                                      icon: Icon(Icons.edit)),
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
                                          backgroundColor: Colors.white
                                      ),
                                      onPressed: () {
                                        // showModalBottomSheet(
                                        //   context: context, builder: (context) => EditBottomSheet(theThing: 'Name',),
                                        //   isScrollControlled: true,
                                        // );
                                      },
                                      icon: Icon(Icons.edit)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // showModalBottomSheet(
                                  //   context: context, builder: (context) => EditBottomSheet(theThing: 'Income',),
                                  //   isScrollControlled: true,
                                  // );
                                },
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Wallet Balance: \$30,009', style: kSetting,),
                                  trailing: IconButton(
                                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                                    onPressed: () {
                                      // showModalBottomSheet(
                                      //   context: context, builder: (context) => EditBottomSheet(theThing: 'Income',),
                                      //   isScrollControlled: true,
                                      // );
                                    },
                                    icon: Icon(Icons.add),
                                  ),
                                ),
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text('Logout/ Switch Account', style: kSetting,),
                                trailing: IconButton(
                                  color: Colors.red,
                                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                                  onPressed: () async {
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.setBool('isSetupDone', true);
                                    await FirebaseAuth.instance.signOut();
                                    Navigator.pushAndRemoveUntil(
                                      context, MaterialPageRoute(builder: (_) => WelcomeScreen()),
                                          (route) => false,);
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
                                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                                    onPressed: () {launchEmail('SmartSpendSupportCenter');},
                                    icon: Icon(Icons.mail),
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
                                      style: IconButton.styleFrom(backgroundColor: Colors.white),
                                      onPressed:  () {
                                        launchEmail('SmartSpendFeedBack');
                                      },
                                      icon: Icon(Icons.feedback)),
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
                                        style: IconButton.styleFrom(backgroundColor: Colors.white),
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                              PrivacyPolicyPage()));
                                        },
                                        icon: Icon(Icons.chevron_right_sharp)),
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