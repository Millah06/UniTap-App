import 'package:everywhere/components/reusable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../constraints/constants.dart';
import '../services/brain.dart';
import 'flush_bar_message.dart';

class AccountInformation extends StatelessWidget {

  const AccountInformation({super.key});

  @override
  Widget build(BuildContext context) {
    final pov = Provider.of<Brain>(context);
    final PageController _pageController = PageController(viewportFraction: 0.95);
    if (pov.accountData.isEmpty) {
      return Center(child: CircularProgressIndicator(
        value: 20,
        backgroundColor: kCardColor,
        color: kButtonColor,
      ),);
    }
    return  Column(

      children: [
        Container(
          alignment: Alignment.topRight,
          padding: EdgeInsets.only(right: 20),
          child: SmoothPageIndicator(
            controller: _pageController,
            count: 3,
            effect: ExpandingDotsEffect(
              dotColor: Colors.grey,
              activeDotColor: Colors.white,
              dotHeight: 6,
              dotWidth: 6,
            ),
          ),
        ),
        ReusableCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Account Name', style:
                        TextStyle(fontFamily: 'DejaVu Sans', fontSize: 11,
                            color: Colors.white70),),
                        Text(pov.userAccount['account_name'].split('/').sublist(1,2).join(' '),
                          style: TextStyle(fontFamily: 'DejaVu Sans', fontSize: 12,
                              fontWeight: FontWeight.w900),),
                        SizedBox(height: 35,),
                        Text('Account Number', style: TextStyle(fontFamily: 'DejaVu Sans', fontSize: 11, color: Colors.white70),),
                        Row(
                          children: [
                            Text(pov.userAccount['account_number'],
                              style: TextStyle(fontFamily: 'DejaVu Sans',
                                  fontSize: 12, fontWeight: FontWeight.w900),),
                            SizedBox(width: 7,),
                            GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: pov.userAccount['account_number']));
                                  FlushBarMessage
                                      .showFlushBar(
                                      context: context,
                                      message: 'Copied Successfully!'
                                  );
                                },
                                child: Icon(Icons.copy_sharp, size: 15, color: kIconColor,)
                            ),
                            SizedBox(width: 7,),
                            GestureDetector(
                                onTap: () async {
                                  try {
                                    await SharePlus.instance.share(
                                      ShareParams(
                                          subject: 'NexPay Account Details',
                                          title: 'NexPay Account Details',
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
                                child: Icon(Icons.share_rounded, size: 15, color: kIconColor,)
                            )
                          ],
                        ),
                        SizedBox(height: 35,),
                        Text('Wallet Funding Fees', style:
                        TextStyle(fontFamily: 'DejaVu Sans', fontSize: 11,
                            color: Colors.white70),),
                        Text('${kNaira}${pov.fundingFees.toStringAsFixed(2)}',
                          style: TextStyle(fontFamily: 'DejaVu Sans', fontSize: 12,
                              fontWeight: FontWeight.w900),),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bank Name', style: TextStyle(fontFamily: 'DejaVu Sans', fontSize: 11, color: Colors.white70),),
                        Text(pov.userAccount['bank'], style: TextStyle(fontFamily: 'DejaVu Sans', fontSize: 12, fontWeight: FontWeight.w900),),
                        SizedBox(height: 35,),
                        Text('Status', style: TextStyle(fontFamily: 'DejaVu Sans', fontSize: 11, color: Colors.white70),),
                        Text(pov.userAccount['status'].toString().replaceAll('a', 'A'),
                          style: TextStyle(fontFamily: 'DejaVu Sans',
                              fontSize: 12, fontWeight: FontWeight.w900),),
                        SizedBox(height: 35,),
                        Text('Other Fees', style:
                        TextStyle(fontFamily: 'DejaVu Sans', fontSize: 11,
                            color: Colors.white70),),
                        Text('None',
                          style: TextStyle(fontFamily: 'DejaVu Sans', fontSize: 12,
                              fontWeight: FontWeight.w900),),
                      ],
                    )
                  ],
                ),

              ],
            )),
      ],
    );
  }
}
