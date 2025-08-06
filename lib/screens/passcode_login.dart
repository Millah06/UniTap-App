import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:everywhere/components/bootom_bar.dart';
import 'package:everywhere/components/flush_bar_message.dart';
import 'package:everywhere/constraints/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../components/pin_entry.dart';
import '../services/brain.dart';
import 'login_screen.dart';

class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({super.key});

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {

  bool obscureText = true;

  void _auth(Future<bool> canAuth) async {
    final LocalAuthentication auth = LocalAuthentication();
    if (await canAuth) {
      final result = await auth.authenticate(
          localizedReason: 'Use Fingerprint to login',
          options: const AuthenticationOptions(biometricOnly: true)
      );
      result ? Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => BottomBar()),
            (route) => false) :
      FlushBarMessage.showFlushBar(
        context: context,
        message: 'Your device does\'nt support this method, use passcode instead.',
        title: 'Ops',
        icon: Icon(Icons.error_outline,
          color: kErrorIconColor, size: 30,),
      );
    }
    else {
      FlushBarMessage.showFlushBar(
        context: context,
        message: 'Your device does\'nt support this method, use passcode instead.',
        title: 'Ops',
        icon: Icon(Icons.error_outline,
          color: kErrorIconColor, size: 30,),
      );
    }
  }

  final TextEditingController _controller = TextEditingController();
  String textDigit = '';
  Color buttonColor = Color(0x3321DEED);
  Color textColor = Colors.white60;

  @override
  Widget build(BuildContext context) {
    final pov = Provider.of<Brain>(context);
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 50, bottom: 0, left: 0, right: 0),
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 0, left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(image: AssetImage('images/eraser.png'), height: 60,
                    fit: BoxFit.cover, width: 60,),
                  SizedBox(height: 30,),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color:  Colors.white,
                            width: 3
                        )
                    ),
                    child: ClipOval(
                        child: Image.file(File(pov.image), fit: BoxFit.cover,)
                    ),
                  ),
                  SizedBox(height: 20,),
                  Text(pov.user, style:
                  GoogleFonts.inter(fontWeight: FontWeight.w900,
                    fontSize: 18, letterSpacing: 0.5, height: 0),),
                  SizedBox(height: 30,),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black38
                      ),
                      child: TextFormField(
                        controller: _controller,
                        readOnly: true,
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.security),
                          hintText: '6-digit PassCode',
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                              icon: Icon(obscureText ? FontAwesomeIcons.eyeSlash :
                              FontAwesomeIcons.eye, size: 18,)
                          ),
                        ),
                        onChanged: (value) {
                          textDigit = value;

                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  "Forgot PassCode?",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: kButtonColor,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                   if (_controller.text.length == 6) {
                     showDialog(
                       context: context,
                       barrierDismissible: false,
                       builder: (context) => Center(
                         child: CircularProgressIndicator(
                           value: 20,
                           backgroundColor: kCardColor,
                           color: kButtonColor,
                         ),
                       ),
                     );
                     if (pov.localPasscode == _controller.text) {

                       Navigator.pushAndRemoveUntil(
                         context, MaterialPageRoute(builder: (_) => BottomBar()), (route) => false,);
                     }
                     else {
                       Navigator.pop(context);
                       FlushBarMessage.showFlushBar(
                           context: context,
                           message: 'Incorrect PassCode',
                         title: 'Ops',
                         icon: Icon(Icons.error_outline,
                           color: kErrorIconColor, size: 30,),
                       );
                     }
                   }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100)
                ),
                child: Text('Login Now', style:
                GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w700, fontSize: 18)),
              ),
            ),
            CustomPinKeyboard(
              onKeyTap: (digit ) {
                if (_controller.text.length < 6) {
                  _controller.text += digit;
                }
                if (_controller.text.length == 6) {
                  setState(() {
                    buttonColor = Color(0xFF21D3ED);
                    textColor = Colors.white;
                  });
                }
              },
              onBackspace: () {
                if (_controller.text.isNotEmpty) {
                  _controller.text = _controller.text.substring(0, _controller.text.length - 1);
                  setState(() {
                    buttonColor = Color(0x3321DEED);
                    textColor = Colors.white60;
                  });
                }
              },
              onBiometric: () {
                _auth(pov.canAuthenticate());
              },
            )
          ],
        ),
      ),
    );
  }
}

