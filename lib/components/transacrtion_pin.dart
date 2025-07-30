import 'package:everywhere/components/pin_entry.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../services/brain.dart';

 class TransactionPin extends StatelessWidget {

   final Function(String) onCompleted;
   final Function() onForgotPin;
   const TransactionPin({super.key, required this.onCompleted, required this.onForgotPin});

   @override
   Widget build(BuildContext context) {
     return FractionallySizedBox(
       heightFactor: 0.55,
       child:  PinEntryScreen(
           onCompleted: onCompleted,
           onForgotPin: onForgotPin,
           onBiometricPressed: () async {
             final LocalAuthentication auth = LocalAuthentication();
             final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
             final bool canAuthenticate =
                 canAuthenticateWithBiometrics || await auth.isDeviceSupported();
             if (canAuthenticate) {
               await auth.authenticate(
                   localizedReason: 'Use Fingerprint to confirm transaction',
                   options: const AuthenticationOptions(biometricOnly: true)
               );
             }
           }
       ),
     );
   }
 }

