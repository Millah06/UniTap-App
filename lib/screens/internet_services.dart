import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everywhere/models/internet_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../components/confirmation_page.dart';
import '../components/order_frame.dart';
import '../components/transacrtion_pin.dart';
import '../constraints/constants.dart';
import '../models/plan_model.dart';
import '../services/brain.dart';
import '../services/purchase_service.dart';
import '../services/transaction_service.dart';

class InternetServicesScreen extends StatefulWidget {
  const InternetServicesScreen({super.key});

  @override
  State<InternetServicesScreen> createState() => _InternetServicesScreenState();
}

class _InternetServicesScreenState extends State<InternetServicesScreen> with TickerProviderStateMixin {

  TabController ? _tabController;

  Map<String, List<InternetCategoryData>> _categories = {};
  bool isLoading = true;
  String _selectedNetwork = 'Smile Network';

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
          length: _categories[_selectedNetwork]!.length, vsync: this);
      isLoading = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController?.dispose();
    super.dispose();
  }

  final TextEditingController _phoneController = TextEditingController();

  List networks = ['Smile Network', 'Spectra Net'];
  final _formKey = GlobalKey<FormState>();

  Future<Map<String, List<InternetCategoryData>>> fetchCategories() async {
    final ref = FirebaseDatabase.instanceFor( app: Firebase.app(),
        databaseURL: "https://everywhere-9278c-default-rtdb.europe-west1.firebasedatabase.app/"
    ).ref('internetServices');
    final snapshot = await ref.get();

    if (!snapshot.exists) throw Exception('No data found');

    final Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);

    final Map<String, List<InternetCategoryData>> result = {};

    data.forEach((networkKey, categoryListRaw) {
      final List<dynamic> categoryList = List<dynamic>.from(categoryListRaw);

      final List<InternetCategoryData> categoryDataList = categoryList.map((categoryRaw) {
        final Map<String, dynamic> categoryMap = Map<String, dynamic>.from(categoryRaw);
        return InternetCategoryData.fromMap(categoryMap);
      }).toList();

      result[networkKey] = categoryDataList;
    });

    return result;
  }

  Widget _buildPlanGrid(List<InternetPlan> plans, int tabIndex) {
    int ? selectedIndex = _selectedIndices[tabIndex];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 15, left: 0, right: 0),
      child: GridView.builder(
          gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.7,
            crossAxisSpacing: 30,
            mainAxisSpacing: 15,
            // mainAxisExtent: 120
          ),
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
                            color: isSelected ? kButtonColor : kCardColor, width: 2)
                    ),
                    padding: EdgeInsets.only(left: 0, right: 0, top: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(plan.description,
                              style: TextStyle(color: Colors.white,
                                  fontSize: 12, fontWeight: FontWeight.w900), textAlign: TextAlign.center,),
                            SizedBox(height: 4,),
                            Text(plan.duration, style: TextStyle(color: Colors.white54),),
                            SizedBox(height: 6,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('₦',  style: TextStyle(color: Colors.white54,
                                    fontWeight: FontWeight.w700, fontSize: 13)),
                                SizedBox(width: 3,),
                                Text(plan.price.split('.').first,
                                  style: TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.w700, fontSize: 18),),
                              ],
                            ),
                          ],
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
                              style: TextStyle(color: Colors.black, fontSize: 10,
                                  fontWeight: FontWeight.w700), textAlign: TextAlign.center,)),
                          )
                      ],
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                        top: 4,
                        right: 2,
                        child: Icon(Icons.check_circle)
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
          title: Text('Internet Services'),
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
                        value: _selectedNetwork,
                        menuMaxHeight: 200,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        decoration: const InputDecoration(
                          labelText: 'Network',
                          labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
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
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                        maxLength: 10,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefix: Text('+234 | ',
                            style: TextStyle(color: Colors.white, fontSize: 16,
                                fontWeight: FontWeight.w900),),
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
                      ),
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Text('Data Plans', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),),
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
    final pov = Provider.of<Brain>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Internet Services'),
      ),
      body: Form(
        key: _formKey,
        child: Container(
            padding: EdgeInsets.only(left: 15, right: 15, top: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
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
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefix: Text('+234 | ',
                      style: TextStyle(color: Colors.white, fontSize: 14,
                          fontWeight: FontWeight.w900),),
                    hintText: '8023344567',
                    labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Text('Data Plans', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),),
                ),
                Container(
                  color: Color(0xFF0F172A),
                  padding: EdgeInsets.only(top: 10),
                  child: TabBar(
                    controller: _tabController,
                    tabs: [
                      ...?_categories[_selectedNetwork]?.map((x) => Text(x.category)),
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
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ...List.generate(
                          _categories[_selectedNetwork]!.length,
                              (index) {
                            return  _buildPlanGrid(
                                _categories[_selectedNetwork]![index].plans, index);
                          }
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: EdgeInsets.only(bottom: 30),
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
                              final plan = _categories[_selectedNetwork]?[tabIndex].plans[selectedIndex];
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) =>
                                      ConfirmationPage(
                                        productName: 'data',
                                        amount: '${plan?.price}',
                                        recipientMobile: _phoneController.text,
                                        onTap: () {
                                          TransactionService.handlePurchase(
                                              amount: plan!.price,
                                              context: context,
                                              purchaseFunction: () async {
                                                try {
                                                  final res = await PurchaseItems().purchaseSmile(
                                                    _selectedNetwork, plan.variationCode,
                                                  );
                                                  return res;
                                                }
                                                catch (e) {
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
                          child: Text('Buy Now', style: TextStyle(color: Colors.white),)
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
            )
        ),
      ),
    );
  }
}
