import 'dart:ui' as BorderType;

import 'package:dotted_border/dotted_border.dart';
import 'package:everywhere/components/reusable_card.dart';
import 'package:everywhere/services/purchase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/confirmation_page.dart';
import '../constraints/constants.dart';
import '../models/tv_model.dart';
import '../services/transaction_service.dart';

class CableSubscription extends StatefulWidget  {
  const CableSubscription({super.key});

  @override
  State<CableSubscription> createState() => _CableSubscriptionState();
}

class _CableSubscriptionState extends State<CableSubscription> with TickerProviderStateMixin {

  TabController ? _tabController;

  Map<String, List<TvCategoryData>> _categories = {};
  bool isLoading = true;
  String _selectedProvider = 'DStv';
  bool readyToShowName = false;
  bool addIsTouch = false;

  final Map<int, int?> _selectedIndices = {};

  @override
  void initState() {
    // TODO: implement initState
    _fetchData();
    super.initState();
  }

  Future<void> _fetchData() async  {
    final fetchedCategories = await fetchCategories();
    setState(() {
      _categories = fetchedCategories;
      _tabController = TabController(
          length: _categories[_selectedProvider]!.length, vsync: this);
      isLoading = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController?.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  List providers = ['DStv', 'GOtv', 'StarTimes', 'SHOWMAX'];
  final _formKey = GlobalKey<FormState>();
  Future<Map<String, dynamic>?>? customerDetails;

  Future<Map<String, List<TvCategoryData>>> fetchCategories() async {
    final ref = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: "https://everywhere-9278c-default-rtdb.europe-west1.firebasedatabase.app/"
    ).ref('tv');
    final snapshot = await ref.get();

    if (!snapshot.exists) throw Exception('No data found');

    final Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);

    final Map<String, List<TvCategoryData>> result = {};

    data.forEach((networkKey, categoryListRaw) {
      final List<dynamic> categoryList = List<dynamic>.from(categoryListRaw);

      final List<TvCategoryData> categoryDataList = categoryList.map((categoryRaw) {
        final Map<String, dynamic> categoryMap = Map<String, dynamic>.from(categoryRaw);
        return TvCategoryData.fromMap(categoryMap);
      }).toList();

      result[networkKey] = categoryDataList;
    });

    return result;
  }


  Widget _buildPlanGrid(List<TvPlan> plans, int tabIndex) {
    int ? selectedIndex = _selectedIndices[tabIndex];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 15, left: 0, right: 0),
      child: GridView.builder(
          gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 30,
              mainAxisSpacing: 15,
          ),
          shrinkWrap: true,
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            bool isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndices[tabIndex] = index;
                  isSelected = !isSelected;
                });
              },
              child: Stack(
                children: [
                  Container(
                    width: 150,
                    decoration: BoxDecoration(
                        color: isSelected ? Colors.transparent : kCardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isSelected ? kButtonColor : kCardColor, width: 1.5)
                    ),
                    padding: EdgeInsets.only(left: 0, right: 0, top: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(plan.description,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white,
                                            fontSize: 12, fontWeight: FontWeight.w700),),
                                      SizedBox(height: 4,),
                                      Text(plan.duration,
                                        style: TextStyle(color: Colors.white54,
                                            fontWeight: FontWeight.w700, fontSize: 15),),
                                      SizedBox(height: 6,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('₦',  style: TextStyle(color: Colors.white54,
                                              fontWeight: FontWeight.w700, fontSize: 14)),
                                          SizedBox(width: 3,),
                                          Text(kFormatterNo.format(double.tryParse(plan.price.split('.').first)),
                                            style: TextStyle(color: Colors.white,
                                                fontWeight: FontWeight.w700, fontSize: 20),),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                        Container(
                            height: 15,
                            width: 150,
                            decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(12),
                                    bottomLeft: Radius.circular(12)
                                )
                            ),
                            child: Center(child: Text('$kNaira${double.parse(plan.price) * 0.01} cashback',
                              style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w700),)),
                          )
                      ],
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                        top: 4,
                        right: 2,
                        child: Icon(Icons.check_circle, color: Color(0xFF21D3ED), size: 18,)
                    )
                ],
              ),
            );
          }
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Cable Subscription'),
        ),
        body: Form(
          key: _formKey,
          child: Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        dropdownColor: kCardColor,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        iconSize: 30,
                        iconDisabledColor: kButtonColor,
                        iconEnabledColor: kButtonColor,
                        value: _selectedProvider,
                        menuMaxHeight: 200,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        decoration: const InputDecoration(
                          labelText: 'Providers',
                          labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                        // style: const TextStyle(color: Colors.black),
                        items: providers.map((range) {
                          return DropdownMenuItem<String>(
                              value: range,
                              child: Text(range, style: TextStyle(color: Colors.white),));
                        }).toList(),
                        onChanged: (val) {
                          // else if (val != null) {setState(() => selectedDateRange = val);};

                          setState(() {
                            _selectedProvider = val!;
                            _selectedIndices.clear();
                            _tabController?.dispose();
                            _tabController = TabController(
                                length: _categories[_selectedProvider]!.length,
                                vsync: this,
                                initialIndex: 0
                            );
                          });
                        },
                      ),
                      SizedBox(height: 20,),
                      TextFormField(
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefix: _selectedProvider == 'StarTimes ON'
                              || _selectedProvider == 'SHOWMAX' ? Text('+234 | ',
                            style: TextStyle(color: Colors.white, fontSize: 16,
                                fontWeight: FontWeight.w900),) : Text(''),
                          labelText: _selectedProvider == 'StarTimes ON'
                              || _selectedProvider == 'SHOWMAX' ? 'Enter Your Mobile Number'
                              : 'Enter Your Smartcard Number',
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
                      Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Text('TV Plans', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: 20,
                            backgroundColor: kCardColor,
                            color: kButtonColor,
                          ),
                          SizedBox(height: 5,),
                          Text('Loading data...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white70),)
                        ],
                      ),
                    ),
                  ),
                ],
              )
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Cable Subscription'),
      ),
      body: Form(
        key: _formKey,
        child: Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  dropdownColor: kCardColor,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  iconSize: 25,
                  iconDisabledColor: kButtonColor,
                  iconEnabledColor: kButtonColor,
                  value: _selectedProvider,
                  menuMaxHeight: 200,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  decoration: const InputDecoration(
                    labelText: 'Providers',
                    labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                  // style: const TextStyle(color: Colors.black),
                  items: providers.map((range) {
                    return DropdownMenuItem<String>(
                        value: range,
                        child: Text(range, style: TextStyle(color: Colors.white),));
                  }).toList(),
                  onChanged: (val) {
                    // else if (val != null) {setState(() => selectedDateRange = val);};

                    setState(() {
                      _selectedProvider = val!;
                      _selectedIndices.clear();
                      _tabController?.dispose();
                      _tabController = TabController(
                          length: _categories[_selectedProvider]!.length,
                          vsync: this,
                          initialIndex: 0
                      );
                    });
                  },
                ),
                SizedBox(height: 20,),
                TextFormField(
                  controller: _phoneController,
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefix: _selectedProvider == 'StarTimes ON'
                        || _selectedProvider == 'SHOWMAX' ? Text('+234 | ',
                      style: TextStyle(color: Colors.white, fontSize: 14,
                          fontWeight: FontWeight.w900),) : Text(''),
                    labelText: _selectedProvider == 'StarTimes ON'
                        || _selectedProvider == 'SHOWMAX' ? 'Enter Your Mobile Number'
                        : 'Enter Your Smartcard Number',
                    hintText: '8023344567',
                    labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value.length == 10) {
                      customerDetails = PurchaseItems().verifyCable(_phoneController.text,
                          'dstv');
                      PurchaseItems().verifyCable(_phoneController.text, 'dstv');
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
                SizedBox(height: 15,),
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
                                    value: 5,
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
                                        // color: Color(0xFF1E293B),
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
                                                Text('Merchant Name', style: TextStyle(fontSize: 11),),
                                                Text('Current plan', style: TextStyle(fontSize: 11),),
                                                Text('Due Date', style: TextStyle(fontSize: 11),)
                                              ],
                                            ),
                                            SizedBox(width: 10,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(snapshot.data?['name'],
                                                  style:
                                                  TextStyle(fontWeight: FontWeight.w900, fontSize: 12),),
                                                Text('${snapshot.data?['status']} to ${snapshot.data?['provider']}',
                                                  style: TextStyle(fontWeight:
                                                  FontWeight.w900, fontSize: 12),),
                                                Text('23st October, 2024', style:
                                                TextStyle(fontWeight: FontWeight.w900, fontSize: 12),)
                                              ],
                                            ),
                                          ],
                                        ),
                                        Visibility(
                                          replacement: Container(),
                                          visible: !addIsTouch,
                                          child: Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: DottedBorder(
                                              options: RectDottedBorderOptions(
                                                  color: Colors.white70,
                                                  strokeWidth: 2,
                                                  dashPattern: [6, 2]
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    addIsTouch = true;
                                                  });
                                                },
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
                                        color: addIsTouch ? Color(0xFF21D3ED)
                                            : Colors.white70,
                                        size: 20,
                                      )
                                  ),
                                ]
                              );
                            }
                        )
                      ],
                    )
                ),
                SizedBox(height: 15,),
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Text('TV Plans', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),),
                ),
                if (_categories[_selectedProvider] == null)
                  Center(
                    child: Text('No plan available for this Provider!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),),
                  ),
                Container(
                  color: Color(0xFF0F172A),
                  padding: EdgeInsets.only(top: 10),
                  child: TabBar(
                    controller: _tabController,
                    tabs: [
                      ...?_categories[_selectedProvider]?.map((x) =>
                          Text(x.category)),
                    ],
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    dividerHeight: 0,
                    labelColor: Colors.white,
                    labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                    labelPadding: EdgeInsets.only(right: 30, bottom: 5),
                    indicatorColor: Color(0xFF21D3ED),
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 2, color:  Color(0xFF21D3ED)),
                      insets: EdgeInsets.symmetric(horizontal: 0),
                    ),
                  ),
                ),
                if (_categories[_selectedProvider] == null)
                  Center(
                    child: Text('No plan available for this Provider!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),),
                  ),
                Expanded(
                  flex: readyToShowName ? 6 : 10,
                  child: TabBarView(
                    key: ValueKey<String>(_selectedProvider),
                    controller: _tabController,
                    children: [
                      ...List.generate(
                          _categories[_selectedProvider]!.length,
                              (index) {
                            return  _buildPlanGrid(
                                _categories[_selectedProvider]![index].tvPlans,
                                index);
                          }
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Expanded(
                  flex: 2,
                  child: Padding(
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
                              int tabIndex = _tabController!.index;
                              int? selectedIndex = _selectedIndices[tabIndex];
                              if (_formKey.currentState!.validate()) {
                                if (selectedIndex == null) {
                                  ScaffoldMessenger
                                      .of(context).
                                  showSnackBar(SnackBar(content: Text('Please!, select a plan')));
                                  return;
                                }
                                final plan = _categories[_selectedProvider]?[tabIndex].tvPlans[selectedIndex];

                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) =>
                                        ConfirmationPage(
                                          productName: 'Cable Subscription',
                                          amount: '${plan?.price}',
                                          recipientMobile: _phoneController.text,
                                          onTap: () {
                                            TransactionService.handlePurchase(

                                              amount: plan!.price,
                                                context: context,
                                                buildData: (Map<String, dynamic> response) {
                                                  return {
                                                    'Product Name' : _selectedProvider,
                                                    'Amount' : '${plan.price} NGN',
                                                    'Phone Number' : '0${_phoneController.text}',
                                                    'Token' : '${response['token']}',
                                                    'Plan' : plan.description,
                                                    'Transaction ID' : '${response['transaction_ID']}'
                                                  };
                                                },
                                                purchaseFunction: () async {
                                                try {
                                                  final res = await PurchaseItems()
                                                      .purchaseTV(
                                                      plan.variationCode,
                                                      _selectedProvider
                                                  );
                                                  return res;
                                                }
                                                catch(e) {
                                                  rethrow;
                                                }
                                                },
                                                onSuccessExtras: () async {},
                                                onFailureExtras: () async {}
                                            );
                                          },
                                        )
                                );
                              }
                            },
                            child: Text('Buy Now', style: TextStyle(color:  Colors.black,),)
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
                ),
              ],
            )
        ),
      ),
    );
  }
}
