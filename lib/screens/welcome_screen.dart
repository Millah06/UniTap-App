
import 'package:everywhere/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constraints/constants.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {

  static String id = 'welcome';
  const WelcomeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Container(
        padding: EdgeInsets.only(top: 100, left: 0, right: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome to',
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900),),
                Image(image: AssetImage('images/eraser.png'), height: 120,
                  fit: BoxFit.cover, width: 120,),
                SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Text('The safest, most reliable and '
                      'trusted VTU service platform, used by resellers, agents'
                      ' and digital digital bosses.'
                      '\n\nPower your hustle with data, airtime, electricity, '
                      'exams, and more - all in one super powerful app.',
                    style: TextStyle(fontWeight: FontWeight.w900), textAlign: TextAlign.center,),
                )
              ],
            ),
            Flexible(
              child: BottomSheet(
                showDragHandle: true,
                backgroundColor: Color(0xFF1E293B),
                onClosing: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)
                  => LoginScreen())); },
                builder: (BuildContext context) {
                  return FractionallySizedBox(
                    widthFactor: 1,
                    heightFactor: 0.8,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Let\'s get started like a PRO 🦾',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),),
                          ElevatedButton(
                            onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)
                            => LoginScreen()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF21D3ED),
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100)
                            ),
                            child: Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)
                              => SignUpScreen()));
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                elevation: 4,
                                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                                side: BorderSide(
                                    color: kButtonColor
                                )
                            ),
                            child: Text('New user',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),),
                          )
                        ],
                      ),
                    ),
                  );
                  },
              ),
            )
          ],
        ),
      ),
    );
  }
}
