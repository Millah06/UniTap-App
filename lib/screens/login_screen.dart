
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:everywhere/screens/profile_picture.dart';
import 'package:everywhere/screens/security2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../components/bootom_bar.dart';
import '../constraints/constants.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {

  static String id = 'login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Color iconColor = Colors.white54;
  bool enable = true;
  bool obscureText = true;
  bool obscureText2 = true;
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _password1controller = TextEditingController();
  final TextEditingController _password2controller = TextEditingController();

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

  // In your authentication screen
  Future<void> _sendPasswordResetEmail(BuildContext context, String email) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Close loading
      Navigator.pop(context);

      // Show success
      Flushbar(
        title: 'Email Sent',
        message: 'Password reset link sent to $email',
        duration: Duration(seconds: 5),
        backgroundColor: Colors.green,
      ).show(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading

      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = 'Error sending reset email: ${e.message}';
      }

      Flushbar(
        title: 'Error',
        message: message,
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
      ).show(context);
    } catch (e) {
      Navigator.pop(context);
      Flushbar(
        title: 'Error',
        message: 'An unexpected error occurred',
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
      ).show(context);
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: 'Enter your registered email',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isEmpty || !emailController.text.contains('@')) {
                Flushbar(
                  title: 'Invalid Email',
                  message: 'Please enter a valid email address',
                  duration: Duration(seconds: 3),
                  backgroundColor: Colors.red,
                ).show(context);
                return;
              }

              await _sendPasswordResetEmail(
                  context,
                  emailController.text
              );
              Navigator.pop(context);
            },
            child: Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _password2controller.dispose();
    _password1controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Container(
          padding: EdgeInsets.only(top: 50, left: 0, right: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 15),
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
                  title: Text('Go Back', style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 20),
                child: Text('Login to your account',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900, color: kButtonColor),
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
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
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

                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: GestureDetector(
                                  onTap: () {
                                    _showForgotPasswordDialog(context);
                                  },
                                  child: const Text(
                                    "Forgot PassCode?",
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: kButtonColor,
                                      fontWeight: FontWeight.w900,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      // Center(
                      //   child: ElevatedButton(
                      //     onPressed: () async {
                      //       // if (!_formKey.currentState!.validate()) {
                      //       //   Navigator.pop(context);
                      //       //   Navigator.push(context, MaterialPageRoute(builder: (context)
                      //       //   => BottomBar()));
                      //       // }
                      //       await Authentication().userSignIn(
                      //           _emailController.text,
                      //           _password1controller.text
                      //       );
                      //       Navigator.pop(context);
                      //       Navigator.push(context, MaterialPageRoute(builder: (context)
                      //       => Security2Screen()));
                      //     },
                      //     style: ElevatedButton.styleFrom(
                      //         backgroundColor: kButtonColor,
                      //         padding: EdgeInsets.symmetric(vertical: 15, horizontal: 130)
                      //     ),
                      //     child: Text('Proceed',
                      //         style: TextStyle(color: Colors.white,
                      //             fontWeight: FontWeight.w700, fontSize: 18)
                      //     ),
                      //   ),
                      // ),
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
                                await Authentication().userSignIn(
                                  _emailController.text,
                                  _password1controller.text,
                                );
                                // Close loading spinner
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => Security2Screen()),
                                );
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

                              } on FirebaseAuthException catch (e) {
                                // Close loading spinner
                                Navigator.pop(context);
                                // Show error message
                                Flushbar(
                                  title: 'Login Failed',
                                  message: e.message,
                                  borderRadius: BorderRadius.circular(12),
                                  backgroundColor: Color(0xFF1E293B),
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



