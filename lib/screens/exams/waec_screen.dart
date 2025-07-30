import 'package:everywhere/components/confirmation_page.dart';
import 'package:everywhere/components/transacrtion_pin.dart';
import 'package:everywhere/constraints/constants.dart';
import 'package:flutter/material.dart';

class WaecServices extends StatefulWidget {
  const WaecServices({super.key});

  @override
  State<WaecServices> createState() => _WaecServicesState();
}

class _WaecServicesState extends State<WaecServices> {

  String _selectedNetwork = 'MTN';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  List networks = ['MTN', 'Airtel', 'Glo', '9mobile'];
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('WAEC Services'),
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
                    iconEnabledColor: Colors.white,
                    value: _selectedNetwork,
                    menuMaxHeight: 200,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    decoration: const InputDecoration(
                      labelText: 'Service Type',
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
                  TextFormField(
                    controller: _amountController,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      hintText: 'N3450',
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
                  TextFormField(
                    controller: _phoneController,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    keyboardType: TextInputType.phone,
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
                      return null;
                    },
                  ),
                  SizedBox(height: 20,),
                  DropdownButtonFormField<String>(
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    dropdownColor: kCardColor,
                    padding: EdgeInsets.only(left: 10, right: 10),
                    iconSize: 30,
                    iconEnabledColor: Colors.white,
                    value: _selectedNetwork,
                    menuMaxHeight: 200,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    decoration: const InputDecoration(
                      labelText: 'Network operator',
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
                                        productName: 'airtime',
                                        amount: _amountController.text,
                                        recipientMobile: _phoneController.text,
                                        onTap: () {
                                          showModalBottomSheet(
                                              isScrollControlled: true,
                                              context: context, builder: (context) =>
                                              TransactionPin(onCompleted: (pin) {  }, onForgotPin: () {  },)
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
