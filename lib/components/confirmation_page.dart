import 'package:dotted_border/dotted_border.dart';
import 'package:everywhere/components/reusable_card.dart';
import 'package:everywhere/components/wallet_balance.dart';
import 'package:flutter/material.dart';

import '../constraints/constants.dart';

class ConfirmationPage extends StatelessWidget {

  final String productName;
  final String amount;
  final double? quantity;
  final String recipientMobile;
  final Function() onTap;
  const ConfirmationPage({super.key,
    this.quantity,
    required this.productName,
    required this.amount,
    required this.recipientMobile,
    required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.57,
      child: Column(
        children: [
          Center(
              child: productName == 'Recharge Pins'
                  ? Text('N ${double.tryParse(amount)! * quantity! }', style: kMoneyStyle,)
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(kNaira, style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),),
                  SizedBox(width: 3,),
                  BalanceText(double.tryParse(amount)!, 30, 12)
                ],
              ),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product Name', style: kConfirmationKey,),
                    SizedBox(height: 10,),
                    productName.contains('Electricity')  ?
                    Text('Meter Number', style: kConfirmationKey,)
                        :
                    productName == 'Recharge Pins' ? Text('Business Name',
                      style: kConfirmationKey,) :

                    Text('Recipient Mobile', style: kConfirmationKey,),
                    SizedBox(height: 10,),
                    productName == 'Recharge Pins' ?
                    Text('Value of Each', style: kConfirmationKey,) : Text('Amount', style: kSetting,),
                    SizedBox(height: 10,),
                    Text('Bonus to Earn', style: kConfirmationKey,)

                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(productName, style: kConfirmationValue,),
                    SizedBox(height: 10,),
                    Text(recipientMobile, style: kConfirmationValue,),
                    SizedBox(height: 10,),
                    Text(kFormatter.format(double.parse(amount)), style: kConfirmationValue,),
                    SizedBox(height: 10,),
                    Text(kFormatter.format((double.tryParse(amount)! * 0.035)),
                      style: kConfirmationValue,)
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: 20,),
          Container(
            margin: EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xFF1E293B),
            ),
            child: DottedBorder(
              options: RoundedRectDottedBorderOptions(
                  radius: Radius.circular(10),
                padding: EdgeInsets.only(bottom: 10, left: 15, right: 15, top: 10),
                color: Colors.white
              ),
              child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Available Balance ()', style: kSetting.copyWith(fontWeight: FontWeight.w900),),
                        Icon(Icons.check)
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Balance After Transaction', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15 ),),
                        Row(
                          children: [
                            Text(kNaira, style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),),
                            SizedBox(width: 3,),
                            BalanceText(56096.67, 16, 8)
                          ],
                        ),
                      ],
                    )
                  ],
                ),
            ),
          ),
          SizedBox(height: 20,),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kButtonColor,
                  elevation: 4,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 110)
              ),
              onPressed: onTap,
              child: Text('Buy Now', style: TextStyle(color: Colors.white),)
          ),
        ],
      ),
    );
  }
}

