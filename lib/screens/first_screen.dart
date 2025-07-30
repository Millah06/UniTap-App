import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:everywhere/components/bootom_bar.dart';
import 'package:everywhere/constraints/constants.dart';
import 'package:everywhere/screens/passcode_login.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../components/flush_bar_message.dart';
import '../services/brain.dart';
import 'login_screen.dart';

class FirstScreen extends StatefulWidget {

  static String id = 'First';
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    final brain = Provider.of<Brain>(context, listen: false);
    await brain.getData();

  }

  void _auth(Future<bool> canAuth) async {
    final LocalAuthentication auth = LocalAuthentication();
    if (await canAuth) {
      bool result = await auth.authenticate(
          localizedReason: 'Use Fingerprint to login',
          options: const AuthenticationOptions(biometricOnly: true)
      );
      result ?  Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => BottomBar()), (route) => false,) :
      FlushBarMessage.showFlushBar(
        context: context,
        message: 'Your device does\'nt support this method, use passcode instead.',
        title: 'Ops',
        icon: Icon(Icons.error_outline,
          color: kErrorIconColor, size: 30,),
      );
    }
    else if (await canAuth == false) {
      FlushBarMessage.showFlushBar(
        context: context,
        message: 'Your device does\'nt support this method, use passcode instead.',
        title: 'Ops',
        icon: Icon(Icons.error_outline,
          color: kErrorIconColor, size: 30,),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pov = Provider.of<Brain>(context);
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 50, bottom: 20, left: 15, right: 15),
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(image: AssetImage('images/eraser.png'),
                  height: 90, fit: BoxFit.cover, width: 90,),
                SizedBox(height: 30,),
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color:  Colors.white,
                          width: 3
                      )
                  ),
                  child: ClipOval(
                    child: pov.isLoading ? CircularProgressIndicator() :
                    Image.file(File(pov.imagePath.toString()), fit: BoxFit.cover,)
                  ),
                ),
                SizedBox(height: 20,),
                Text(pov.user, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15,),),
                SizedBox(height: 30,),
                Icon(Icons.fingerprint, size: 70,),
                SizedBox(height: 30,),
                TextButton(onPressed:  () {_auth(pov.canAuthenticate());},
                    child: Text('Click to log in with Fingerprint',
                      style: TextStyle(color: kButtonColor),)),
                Center(
                  child: ElevatedButton(
                    onPressed: () {_auth(pov.canAuthenticate());},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF21D3ED),
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 70)
                    ),
                    child: Text('Verify Fingerprint', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => PasscodeScreen()));
                      },
                      child: Text('Login with Password',
                        style: TextStyle(color: kButtonColor, fontSize: 15, fontWeight: FontWeight.w900),),
                    ),
                    SizedBox(height: 20,),
                    Divider(indent: 50, endIndent: 50,),
                    Text('Powered by SkyNest Innovations',),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
