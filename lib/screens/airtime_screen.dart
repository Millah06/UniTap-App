import 'package:another_flushbar/flushbar.dart';
import 'package:dio/dio.dart';
import 'package:everywhere/components/confirmation_page.dart';
import 'package:everywhere/components/transacrtion_pin.dart';
import 'package:everywhere/constraints/constants.dart';
import 'package:everywhere/services/purchase_service.dart';
import 'package:everywhere/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../services/brain.dart';

class AirtimeScreen extends StatefulWidget {
  const AirtimeScreen({super.key});

  @override
  State<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends State<AirtimeScreen> {

  String _selectedNetwork = 'MTN';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  List networks = ['MTN', 'Airtel', 'Glo', 'etisalat'];
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final pov = Provider.of<Brain>(context);
    return  Scaffold(
      appBar: AppBar(
        title: Text('Airtime Purchase'),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.only(left: 15, right: 15, top: 30),
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  dropdownColor: kCardColor,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  iconSize: 30,
                  iconDisabledColor: kButtonColor,
                  iconEnabledColor: kButtonColor,
                  value: _selectedNetwork,
                  menuMaxHeight: 200,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  decoration: const InputDecoration(
                      labelText: 'Network',
                      labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                  // style: const TextStyle(color: Colors.black),
                  items: networks.map((range) {
                    return DropdownMenuItem<String>(
                        value: range,
                        child: Text(range, style: TextStyle(color: Colors.white),));
                  }).toList(),
                  onChanged: (val) {
                    // else if (val != null) {setState(() => selectedDateRange = val);};
                    setState(() => _selectedNetwork = val!);
                  },
                ),
                SizedBox(height: 20,),
                Form(
                  key: _formKey2,
                  child: TextFormField(
                    controller: _phoneController,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      prefix: Text('+234 | ',
                        style: TextStyle(color: Colors.white, fontSize: 16,
                            fontWeight: FontWeight.w900),),
                        labelText: 'Phone Number',
                        hintText: '8023344567',
                        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field is required';
                      }
                      if (value.startsWith('0', 0)) {
                        return 'Phone number can\'n start with zero';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value.startsWith('0', 0)) {
                        _formKey2.currentState?.validate();
                      }
                      if (value.isEmpty) {
                        _formKey2.currentState?.reset();
                      }
                    },
                  ),
                ),
                SizedBox(height: 20,),
                TextFormField(
                  controller: _amountController,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  cursorColor: Colors.white,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      prefix: Text('$kNaira | ',
                        style: TextStyle(color: Colors.white, fontSize: 16,
                            fontWeight: FontWeight.w900),),
                      labelText: 'Amount',
                      hintText: '300',
                      labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kButtonColor,
                        elevation: 4,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50)
                      ),
                        onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) =>
                                ConfirmationPage(
                                    productName: '$_selectedNetwork airtime',
                                    amount: _amountController.text,
                                    recipientMobile: _phoneController.text,
                                  onTap: () {
                                    Map? data;
                                       TransactionService.handlePurchase(
                                         amount: _amountController.text,
                                           buildData: (Map<String, dynamic> response) {
                                           return {
                                             'Product Name' : '$_selectedNetwork Airtime',
                                             'Amount' : '${_amountController.text} NGN',
                                             'Phone Number' : '0${_phoneController.text}',
                                             'Transaction ID' : '${response['transaction_ID']}'
                                           };
                                           },
                                           context: context,
                                           purchaseFunction: () async {
                                             try {
                                               final res = await PurchaseItems()
                                                   .purchaseAirtime(
                                                   _phoneController.text,
                                                   _selectedNetwork.toLowerCase(),
                                                   _amountController.text
                                               );
                                               return res;
                                             }
                                             catch(e) {
                                               rethrow;
                                             }
                                           },
                                           onSuccessExtras: ()  async {},
                                           onFailureExtras: () async {},
                                       );
                                  },
                                )
                          );
                        }
                        },
                        child: Text('Proceed', style: TextStyle(color: Colors.white),)
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 4,
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                           side: BorderSide(
                             color: kButtonColor
                           )
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('May be Later', style: TextStyle(color: Colors.white),)
                    ),
                  ],
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}
