import 'package:everywhere/components/reusable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/brain.dart';
import 'flush_bar_message.dart';

class AccountInformation extends StatelessWidget {
  const AccountInformation({super.key});

  @override
  Widget build(BuildContext context) {
    final pov = Provider.of<Brain>(context);
    return  ReusableCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account Name', style: TextStyle(fontFamily: 'DejaVu Sans', fontSize: 11, color: Colors.white70),),
                Text(pov.userAccount['account_name'], style: TextStyle(fontFamily: 'DejaVu Sans', fontSize: 12, fontWeight: FontWeight.w900),),
                SizedBox(height: 20,),
                Text('Account Number', style: TextStyle(fontFamily: 'DejaVu Sans', fontSize: 11, color: Colors.white70),),
                Row(
                  children: [
                    Text(pov.userAccount['account_number'], style: TextStyle(fontFamily: 'DejaVu Sans', fontSize: 12, fontWeight: FontWeight.w900),),
                    SizedBox(width: 7,),
                    GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: pov.userAccount['account_number']));
                          FlushBarMessage
                              .showFlushBar(
                              context: context,
                              message: 'Account Number Copied Successfully!'
                          );
                        },
                        child: Icon(Icons.copy_sharp, size: 20,)
                    ),
                    SizedBox(width: 7,),
                    GestureDetector(
                        onTap: () async {
                          try {
                            await SharePlus.instance.share(
                              ShareParams(
                                  subject: 'Elite Pay Account Details',
                                  title: 'Smart Spend Pdf Expense Report',
                                  text: 'Account Name: ${pov.userAccount['account_name']} \n\n Account Number: ${pov.userAccount['account_number']} \n\n'
                                      ' Bank Name: ${pov.userAccount['bank']}'
                              ),
                            );

                          } catch (e) {
                            print("Error generating image: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Something went wrong. Try again!')),
                            );
                          }
                        },
                        child: Icon(Icons.share_rounded, size: 20,)
                    )
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bank Name', style: TextStyle(fontFamily: 'DejaVu Sans', fontSize: 11, color: Colors.white70),),
                Text(pov.userAccount['bank'], style: TextStyle(fontFamily: 'DejaVu Sans', fontSize: 12, fontWeight: FontWeight.w900),),
                SizedBox(height: 20,),
                Text('Status', style: TextStyle(fontFamily: 'DejaVu Sans', fontSize: 11, color: Colors.white70),),
                Text(pov.userAccount['status'].toString().replaceAll('a', 'A'), style: TextStyle(fontFamily: 'DejaVu Sans', fontSize: 12, fontWeight: FontWeight.w900),),
              ],
            )
          ],
        ));
  }
}
