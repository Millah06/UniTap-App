
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:everywhere/constraints/constants.dart';
import 'package:everywhere/screens/bottom_navigation/profile_settings_screen.dart';
import 'package:everywhere/screens/bottom_navigation/promotion.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../screens/bottom_navigation/wallet_screen.dart';
import '../screens/bottom_navigation/home_screen.dart';


class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {

  final PageController _pageController = PageController();

  int selectedIndex = 0;
  final List<Widget> screens = [
    const HomeScreen(),
    const WalletScreen(),
    TemplateSelectionScreen(),
    const  ProfileSettingsScreen()
  ];

  void _onPageChange(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _onItemTapped(int indexSelected) {
    _pageController.jumpToPage(indexSelected);
  }

  Color selectedColor = Color(0xFF6F7E90);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  PageView(
        controller: _pageController,
        onPageChanged: _onPageChange,
        children: screens,
      ),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  CurvedNavigationBar _bottomNavigationBar () {
    return CurvedNavigationBar(
      // backgroundColor: Colors.white60,
      //   buttonBackgroundColor: Color(0xFF177E85),
        color: Color(0xFF334155),

        backgroundColor: Color(0xFF0F172A),
        animationCurve: Curves.decelerate,
        height: 55,
        index: selectedIndex,
        // currentIndex: selectedIndex,
        // // selectedItemColor: Color(0xFFF45F1A) ,
        // selectedItemColor: Colors.white,
        // unselectedItemColor: Color(0xFF6F7E90) ,
        // selectedLabelStyle: TextStyle(color: Colors.white),
        // selectedIconTheme: IconThemeData(size: 25),
        onTap: _onItemTapped,
        items:
        [
          Container(
            margin: EdgeInsets.only(bottom: selectedIndex == 0 ? 0 : 25),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(FontAwesomeIcons.house,
                    size: selectedIndex == 0 ? 15 : 20,
                    color: selectedIndex == 0 ? Color(0xFF21D3ED) :
                    Colors.white38,),
                  Visibility(
                    visible: selectedIndex == 0,
                      child: Text('Home', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),)
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: selectedIndex == 1 ? 0 : 25),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(FontAwesomeIcons.wallet,
                    size: selectedIndex == 1 ? 15 : 20, color: selectedIndex == 1 ? Color(0xFF21D3ED) :
                    Colors.white38,),
                  Visibility(
                      visible: selectedIndex == 1,
                      child: Text('Wallet', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),)
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: selectedIndex == 2 ? 0 : 25),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(FontAwesomeIcons.newspaper,
                    size: selectedIndex == 2 ? 15 : 20, color: selectedIndex == 2 ? Color(0xFF21D3ED) :
                      Colors.white38),
                  Visibility(
                      visible: selectedIndex == 2,
                      child: Text('Chances', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),)
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: selectedIndex == 3 ? 0 : 25),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(FontAwesomeIcons.userGear,
                    size: selectedIndex == 3 ? 15 : 20, color: selectedIndex == 3 ? Color(0xFF21D3ED) :
                      Colors.white38),
                  Visibility(
                      visible: selectedIndex == 3,
                      child: Text('Profile', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),)
                  )
                ],
              ),
            ),
          ),
        ]
    );
  }
}