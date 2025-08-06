
import 'package:another_flushbar/flushbar.dart';
import 'package:everywhere/screens/profile_picture.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/bootom_bar.dart';
import '../constraints/constants.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {

  static String id = 'signup';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  Color iconColor = Colors.white54;
  bool enable = true;
  bool obscureText = true;
  bool obscureText2 = true;
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _password1controller = TextEditingController();
  final TextEditingController _password2controller = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Helper functions to get user-friendly error messages
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('user-not-found')) {
      return 'No user found with this email';
    } else if (error.toString().contains('wrong-password')) {
      return 'Incorrect password';
    } else if (error.toString().contains('network-request-failed')) {
      return 'Network error. Please check your connection';
    } else {
      return 'Login failed. Please try again';
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _password2controller.dispose();
    _password1controller.dispose();
    _userNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Container(
          padding: EdgeInsets.only(top: 50,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.white
                    ),
                  ),
                  title: Text('Go Back', style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 15, right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Initial Setup',
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w900, color: kButtonColor),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Icon(Icons.privacy_tip_sharp, color: Colors.white,),
                        SizedBox(width: 5,),
                        Text('TIPS', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900,),)
                      ],
                    ),
                    SizedBox(height: 5,),
                    Text('Make sure to used strong password with working '
                        'email. A password with special characters like; "@", '
                        '"!", "&", "#", "*" etc. It will enhance security to your account. ',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 12,
                          color: Colors.white70),)
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 20, left: 15, right: 15),
                        child: Center(
                          child: Column(
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: Colors.white,
                                style: kInputTextStyle,
                                controller: _userNameController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(FontAwesomeIcons.userLarge, size: 20,),
                                  prefixIconColor: Colors.white,
                                  labelText: 'Name',
                                  hintText: 'John Vonn',
                                  hintStyle: TextStyle(color: Color(0x8AFFFFFF)),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'This field is required';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    _formKey2.currentState!.reset();
                                  }

                                },
                                onTap: () {
                                  setState(() {
                                    iconColor = kButtonColor;
                                  });
                                },
                              ),
                              SizedBox(height: 35,),
                              TextFormField(
                                // decoration: kInputStyle,
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: Colors.white,
                                style: kInputTextStyle,
                                controller: _emailController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email, size: 20,),
                                  prefixIconColor: Colors.white,
                                  labelText: 'Email',
                                  hintText: 'john@gmail.com',
                                  hintStyle: TextStyle(color: Color(0x8AFFFFFF)),

                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'This field is required';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    _formKey2.currentState!.reset();
                                  }

                                },
                                onTap: () {
                                  setState(() {
                                    iconColor = kButtonColor;
                                  });
                                },
                              ),
                              SizedBox(height: 35,),
                              TextFormField(
                                keyboardType: TextInputType.phone,
                                cursorColor: Colors.white,
                                style: kInputTextStyle,
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(FontAwesomeIcons.userLarge, size: 20,),
                                  prefixIconColor: Colors.white,
                                  labelText: 'Phone Number',
                                  hintText: '07021111111',
                                  hintStyle: TextStyle(color: Color(0x8AFFFFFF)),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'This field is required';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    _formKey2.currentState!.reset();
                                  }

                                },
                                onTap: () {
                                  setState(() {
                                    iconColor = kButtonColor;
                                  });
                                },
                              ),
                              SizedBox(height: 35,),
                              TextFormField(
                                controller: _password1controller,
                                keyboardType: TextInputType.visiblePassword,
                                cursorColor: Colors.white,
                                obscureText: obscureText,
                                style: kInputTextStyle,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock),
                                  labelText: 'Password',
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          obscureText = !obscureText;
                                        });
                                      },
                                      icon: Icon(obscureText ? FontAwesomeIcons.eyeSlash :
                                      FontAwesomeIcons.eye, size: 18,)
                                  ),
                                  hintStyle: TextStyle(color: Color(0x8AFFFFFF)),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'This field is required';
                                  }
                                  if (value.length < 6) {
                                    return 'Password characters should be at least six';
                                  }
                                  return null;
                                },
                                onChanged: (value) {

                                },
                                onTap: () {
                                  setState(() {
                                    iconColor = kButtonColor;
                                  });
                                },
                              ),
                              SizedBox(height: 35,),
                              TextFormField(
                                controller: _password2controller,
                                // decoration: kInputStyle,
                                keyboardType: TextInputType.visiblePassword,
                                cursorColor: Colors.white,
                                obscureText: obscureText2,
                                style: kInputTextStyle,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock),
                                  labelText: 'Confirm Password',
                                  hintStyle: TextStyle(color: Color(0x8AFFFFFF)),
                                  suffixIcon: IconButton(
                                      onPressed: () {

                                   setState(() {
                                          obscureText2 = !obscureText2;
                                        });
                                      },
                                      icon: Icon(obscureText2 ? FontAwesomeIcons.eyeSlash :
                                      FontAwesomeIcons.eye, size: 18,)
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'This field is required';
                                  }
                                  if (_password1controller.text.characters != _password2controller.text.characters) {
                                    return 'This password does not match the previous one';
                                  }
                                  return null;
                                },
                                onChanged: (value) {

                                },
                                onTap: () {
                                  setState(() {
                                    iconColor = kButtonColor;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Show loading spinner
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
                              try {
                                // Attempt login
                                await Authentication().userSignUp(
                                    _emailController.text,
                                    _password1controller.text,
                                    _userNameController.text,
                                  _phoneController.text
                                );
                                // Close loading spinner
                                Navigator.pop(context);
                                // Show success message
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => ProfilePicture()),
                                );
                                Flushbar(
                                  title: 'Success',
                                  message: 'Signed up successfully!',
                                  borderRadius: BorderRadius.circular(12),
                                  duration: Duration(seconds: 1),
                                  icon: Icon(Icons.check_circle, color: Colors.green,),
                                  backgroundColor: kErrorBackground,
                                  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  flushbarPosition: FlushbarPosition.TOP,
                                ).show(context);
                              }
                              catch (e) {
                                Navigator.pop(context);
                                Flushbar(
                                  title: 'Sign Up Failed',
                                  message: e.toString(),
                                  borderRadius: BorderRadius.circular(12),
                                  backgroundColor: kErrorBackground,
                                  flushbarPosition: FlushbarPosition.TOP,
                                  icon: Icon(Icons.error_outline,
                                    color: kErrorIconColor, size: 30,),
                                  duration: Duration(seconds: 3),
                                  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                ).show(context);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: kButtonColor,
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 130)
                          ),
                          child: Text('Proceed',
                              style: TextStyle(color: Colors.white,
                                  fontWeight: FontWeight.w700, fontSize: 18)
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

