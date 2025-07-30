import 'package:dotted_border/dotted_border.dart';
import 'package:everywhere/components/electric_plan_frame.dart';
import 'package:everywhere/models/electric_plan.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../components/confirmation_page.dart';
import '../components/order_frame.dart';
import '../constraints/constants.dart';
import '../services/purchase_service.dart';
import '../services/transaction_service.dart';

class ElectricScreen extends StatefulWidget {
  const ElectricScreen({super.key});

  @override
  State<ElectricScreen> createState() => _ElectricScreenState();
}

class _ElectricScreenState extends State<ElectricScreen>  with SingleTickerProviderStateMixin {

  TabController ? _tabController;

  bool readyToShowName = false;
  bool adIsTouch = false;
  Future<Map<String, dynamic>?>? customerDetails;

  String _selectedProvider = 'Jos Electricity';
  String _selectedMeterType = 'Prepaid';
  final TextEditingController _meterNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  List meterType = ['Prepaid', 'Postpaid'];

  Map<String, List<ElectricPlanModel>> electricPlans = {
    'Regular': [
      ElectricPlanModel(amount: '1000'),
      ElectricPlanModel(amount: '200'),
      ElectricPlanModel(amount: '1000'),
      ElectricPlanModel(amount: '200'),
      ElectricPlanModel(amount: '1000'),
    ],
    'Wise Man': [
      ElectricPlanModel(amount: '1000'),
      ElectricPlanModel(amount: '2,00'),
      ElectricPlanModel(amount: '1,000'),
      ElectricPlanModel(amount: '2,00'),
    ],
    'Monthly': [
      ElectricPlanModel(amount: '1000'),
      ElectricPlanModel(amount: '200'),
      ElectricPlanModel(amount: '1000'),
      ElectricPlanModel(amount: '200'),
    ]
  };

  List providers = [
    'Ibadan Electricity',
    'Jos Electricity',
    'Ikeja Electric',
    'PortHarcourt Electricity',
    'Kaduna Electricity',
    'Abuja Electricity',
    'Eko Electricity',
    'Enugu Electricity',
    'Kano Electricity',
    'Benin Electricity',
    'Yola Electricity',
    'Aba Electricity'
  ];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: electricPlans.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Electricity Unit Purchase'),
        ),
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              Positioned(
                right: 10,
                  top: 10,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    alignment: Alignment.topRight,
                    decoration: BoxDecoration(
                      color: Color(0xFF1E293B),
                        border: Border.all(
                            color:  Color(0xFFE3E3E3),
                            width: 0.4
                        )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(FontAwesomeIcons.userPlus, size: 14,),
                          SizedBox(width: 7,),
                          Text('Easily Load from Recent Beneficiary',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),),
                        ],
                      ),
                    ),
                  )
              ),
              Container(
                padding: EdgeInsets.only(left: 10, right: 10, top: 50),
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        dropdownColor: kCardColor,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        iconSize: 25,
                        iconEnabledColor: Colors.white,
                        value: _selectedProvider,
                        menuMaxHeight: 200,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        decoration: const InputDecoration(
                            labelText: 'Provider',
                            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                        ),
                        // style: const TextStyle(color: Colors.black),
                        items: providers.map((range) {
                          return DropdownMenuItem<String>(
                              value: range,
                              child: Text(range, style: TextStyle(color: Colors.white),));
                        }).toList(),
                        onChanged: (val) {
                          // else if (val != null) {setState(() => selectedDateRange = val);};
                          setState(() => _selectedProvider = val!);
                        },
                      ),
                      SizedBox(height: 20,),
                      DropdownButtonFormField<String>(
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        dropdownColor: kCardColor,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        iconSize: 25,
                        iconEnabledColor: Colors.white,
                        value: _selectedMeterType,
                        menuMaxHeight: 200,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        decoration: const InputDecoration(
                            labelText: 'Meter Type',
                            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        // style: const TextStyle(color: Colors.black),
                        items: meterType.map((range) {
                          return DropdownMenuItem<String>(
                              value: range,
                              child: Text(range, style: TextStyle(color: Colors.white, fontSize: 14),));
                        }).toList(),
                        onChanged: (val) {
                          // else if (val != null) {setState(() => selectedDateRange = val);};
                          setState(() => _selectedMeterType = val!);
                        },
                      ),
                      SizedBox(height: 20,),
                      TextFormField(
                        controller: _meterNumberController,
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Meter Number',
                            hintText: '28023344567',
                            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),

                        ),
                        onChanged: (value) {
                          if (value.length == 10) {
                            customerDetails = PurchaseItems().verifyMeter(
                              meterType: _selectedMeterType,
                              meterNumber: _meterNumberController.text,
                              serviceID: _selectedProvider
                            );
                            setState(() {
                              readyToShowName = true;
                            });
                          }
                          else if (value.length < 10) {
                            setState(() {
                              readyToShowName = false;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 10,),
                      Visibility(
                          visible: readyToShowName,
                          child: Column(
                            children: [
                              FutureBuilder<Map<String, dynamic>?>(
                                  future: customerDetails,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: 10,
                                          backgroundColor: kCardColor,
                                          color: kButtonColor,
                                        ),
                                      );
                                    }
                                    return Stack(
                                      children: [
                                        Container(
                                        padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Color(0xFF1E293B),
                                              border: Border.all(
                                                  color: Colors.white70,
                                                  width: 0.5
                                              )
                                          ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Name', style: TextStyle(fontSize: 11),),
                                                    Text('Address', style: TextStyle(fontSize: 11),),
                                                    Text('Minimum Purchase',
                                                      style: TextStyle(fontSize: 11),),
                                                    Text('Meter Type', style: TextStyle(fontSize: 11),)
                                                  ],
                                                ),
                                                SizedBox(width: 10,),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text( snapshot.data?['name'] == '' ? 'ALI GARBA' : snapshot.data?['name'],
                                                      style:
                                                      TextStyle(fontWeight: FontWeight.w900, fontSize: 11),),
                                                    Text(snapshot.data?['address'] == '' ? 'Makarahuta Inuwa Dahiru Road' : snapshot.data?['address'],
                                                      style: TextStyle(fontWeight:
                                                      FontWeight.w900, fontSize: 11),),
                                                    Text(snapshot.data?['minimumPurchase'] == '' ? '${kNaira}200' : snapshot.data?['minimumPurchase'], style:
                                                    TextStyle(fontWeight: FontWeight.w900, fontSize: 11),),
                                                    Text(snapshot.data?['meterType'] ?? 'Prepaid', style:
                                                    TextStyle(fontWeight: FontWeight.w900, fontSize: 11),)
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Visibility(
                                              visible: !adIsTouch,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    adIsTouch = true;
                                                  });
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.only(top: 10),
                                                  child: DottedBorder(
                                                    options: RectDottedBorderOptions(
                                                        color: Colors.white70,
                                                        strokeWidth: 2,
                                                        dashPattern: [6, 2]
                                                    ),
                                                    child: Container(
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                          border: Border(),
                                                          color: Colors.black
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(FontAwesomeIcons.plusCircle),
                                                          SizedBox(width: 10,),
                                                          Text('Add to Beneficiaries')
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                        Positioned(
                                            right: 5,
                                            top: 1,
                                            child: FaIcon(Icons.check_circle,
                                              color: adIsTouch ? Color(0xFF21D3ED) : Colors.white70,)
                                        ),
                                      ]
                                    );
                                  }
                              )
                            ],
                          )
                      ),
                      SizedBox(height: 5,),
                      Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Text('Amount', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),),
                      ),
                      Container(
                        color: Color(0xFF0F172A),
                        padding: EdgeInsets.only(top: 10),
                        child: TabBar(
                          controller: _tabController,
                          tabs: [
                            ...electricPlans.keys.toList().map((x) =>
                                Text(x)),
                          ],
                          tabAlignment: TabAlignment.start,
                          isScrollable: true,
                          dividerHeight: 0,
                          labelColor: Colors.white,
                          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                          labelPadding: EdgeInsets.only(right: 30, bottom: 5),
                          indicatorColor: Color(0xFF21D3ED),
                          indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(width: 2, color:  Color(0xFF21D3ED)),
                            insets: EdgeInsets.symmetric(horizontal: 0),
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      SizedBox(
                        width: 120,
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.ideographic,
                          children: [
                            Expanded(
                              flex: 3,
                                child: Text('$kNaira : ',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),)
                            ),
                            Expanded(
                              flex: 7,
                              child: SizedBox(
                                height: 40,
                                child: TextFormField(
                                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  cursorColor: Colors.white,
                                  controller: _amountController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(bottom: 2),
                                      isDense: true,
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white
                                        )
                                      ),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white
                                        )
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 0,),
                      Container(
                          height: 200,
                          width: double.infinity,
                          margin: EdgeInsets.only(left: 0, right: 0, top: 0),
                          padding: EdgeInsets.only(top: 10, left: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFF1E293B),
                          ),
                          child:  TabBarView(
                            controller: _tabController,
                            children: [
                              ...electricPlans.keys.toList().map((key) {
                                final items = electricPlans[key]!;
                                return GridView.builder(
                                    padding: EdgeInsets.zero,
                                    gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 1,
                                      crossAxisSpacing: 30,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      final service = items[index];
                                      return ElectricPlanFrame(
                                        cashBack: '40',
                                        amount: service.amount,
                                        onTap: () {
                                          setState(() {
                                            _amountController.text = service.amount;
                                          });
                                        },
                                      );
                                    }
                                );
                              })
                            ],
                          )
                      ),
                      SizedBox(height: 10,),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Row(
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
                                              productName: _selectedProvider,
                                              amount: _amountController.text,
                                              recipientMobile: _meterNumberController.text,
                                              onTap: () {
                                                TransactionService.handlePurchase(
                                                    amount: _amountController.text,
                                                    context: context,
                                                    buildData: (Map<String, dynamic> response) {
                                                      return {
                                                        'Product Name' : '$_selectedProvider Subscription',
                                                        'Amount' : '${_amountController.text} NGN',
                                                        'Meter Number' : _meterNumberController.text,
                                                        'Meter Type' : _selectedMeterType,
                                                        'Token' : '${response['token']}',
                                                        'Transaction ID' : '${response['transaction_ID']}'
                                                      };
                                                    },
                                                    purchaseFunction: () async {
                                                      try {
                                                        final res = await PurchaseItems()
                                                            .purchaseElectric(
                                                            _selectedProvider,
                                                            '08087798514',
                                                            _meterNumberController.text,
                                                          _selectedMeterType,
                                                          _amountController.text
                                                        );
                                                        return res;
                                                      }
                                                      catch(e) {
                                                        rethrow;
                                                      }
                                                    },
                                                    onSuccessExtras: ()  async {},
                                                    onFailureExtras: () async {}
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
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
