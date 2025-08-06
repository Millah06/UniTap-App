import 'package:everywhere/screens/bottom_navigation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/edit2.dart';
import '../edit_template.dart';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class TemplateSelectionScreen extends StatelessWidget {
  final List<String> featuredTemplates = [
    'images/appreciation/photo1.jpeg',
    'images/birthday/photo2.jpeg',
    'images/christmas/photo3.jpeg',
    'images/eid/photo4.jpeg',
    'images/friendship/photo5.jpeg',
    'images/graduation/photo6.jpeg',
    'images/love/photo7.jpeg',
    'images/new year/photo2.jpeg',
    'images/valentine/photo4.jpeg',
  ];

  final Map<String, List<String>> categories = {
    'Birthday 🎂': [
      'images/birthday/photo1.jpeg',
      'images/birthday/photo2.jpeg',
      'images/birthday/photo3.jpeg',
      'images/birthday/photo4.jpeg',
      'images/birthday/photo5.jpeg',
      'images/birthday/photo6.jpeg',
      'images/birthday/photo7.jpeg',
      'images/birthday/photo8.jpeg',
    ],
    'Romantic/ Love 💝': [
      'images/love/photo1.jpeg',
      'images/love/photo2.jpeg',
      'images/love/photo3.jpeg',
      'images/love/photo4.jpeg',
      'images/love/photo5.jpeg',
      'images/love/photo6.jpeg',
      'images/love/photo7.jpeg',
    ],
    'Eid 🕌': [
      'images/eid/photo1.jpeg',
      'images/eid/photo2.jpeg',
      'images/eid/photo3.jpeg',
      'images/eid/photo4.jpeg',
      'images/eid/photo5.jpeg',
      'images/eid/photo6.jpeg',
      'images/eid/photo7.jpeg',
      'images/eid/photo8.jpeg',
      'images/eid/photo9.jpeg',
      'images/eid/photo10.jpeg',
      'images/eid/photo11.jpeg',
      'images/eid/photo12.jpeg',
      'images/eid/photo13.jpeg',
      'images/eid/photo14.jpeg',

    ],
    'Christmas 🎄': [
      'images/christmas/photo1.jpeg',
      'images/christmas/photo2.jpeg',
      'images/christmas/photo3.jpeg',
      'images/christmas/photo4.jpeg',
      'images/christmas/photo5.jpeg',
      'images/christmas/photo6.jpeg',
      'images/christmas/photo7.jpeg',
    ],
    'New Year 🗽': [
      'images/new year/photo1.jpeg',
      'images/new year/photo2.jpeg',
      'images/new year/photo3.jpeg',
      'images/new year/photo4.jpeg',
    ],
    'Friendship 🤝': [
      'images/friendship/photo1.jpeg',
      'images/friendship/photo2.jpeg',
      'images/friendship/photo3.jpeg',
      'images/friendship/photo4.jpeg',
      'images/friendship/photo5.jpeg',
      'images/friendship/photo6.jpeg',
      'images/friendship/photo7.jpeg',
      'images/friendship/photo8.jpeg',
      'images/friendship/photo9.jpeg',
      'images/friendship/photo10.jpeg',
      'images/friendship/photo11.jpeg',
      'images/friendship/photo12.jpeg',
      'images/friendship/photo13.jpeg',
      'images/friendship/photo14.jpeg',
      'images/friendship/photo15.jpeg',
    ],
    'Appreciation 🙏': [
      'images/appreciation/photo1.jpeg',
      'images/appreciation/photo2.jpeg',
      'images/appreciation/photo3.jpeg',
      'images/appreciation/photo4.jpeg',
      'images/appreciation/photo5.jpeg',
      'images/appreciation/photo6.jpeg',
      'images/appreciation/photo7.jpeg',
      'images/appreciation/photo8.jpeg',
      'images/appreciation/photo9.jpeg',
      'images/appreciation/photo10.jpeg',
      'images/appreciation/photo11.jpeg',
      'images/appreciation/photo12.jpeg',
      'images/appreciation/photo13.jpeg',
    ],
    'Valentine 💝': [
      'images/valentine/photo1.jpeg',
      'images/valentine/photo2.jpeg',
      'images/valentine/photo3.jpeg',
      'images/valentine/photo4.jpeg',
      'images/valentine/photo5.jpeg',
      'images/valentine/photo6.jpeg',
      'images/valentine/photo7.jpeg',
      'images/valentine/photo8.jpeg',
    ],
    'Graduation 🎓': [
      'images/graduation/photo1.jpeg',
      'images/graduation/photo2.jpeg',
      'images/graduation/photo3.jpeg',
      'images/graduation/photo4.jpeg',
      'images/graduation/photo5.jpeg',
      'images/graduation/photo6.jpeg',
      'images/graduation/photo7.jpeg',
      'images/graduation/photo8.jpeg',
    ],
    'Get Well Soon ❤️‍🩹': [
      'images/ai.png',
      'images/eraser.png',
      'images/ai.png',
      'images/eraser.png',
      'images/profile.png',
      'images/wallet.jpg',
      'images/profile.png',
      'images/wallet.jpg',
    ],
  };

  TemplateSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: categories.keys.length,
        child: Scaffold(
            // backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text('Choose Frame'),
              // backgroundColor: Colors.black,
              bottom: TabBar(
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                dividerHeight: 0,
                labelColor: Colors.white,
                labelStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900),
                labelPadding: EdgeInsets.only(right: 30, bottom: 0, left: 10),
                indicatorColor: Color(0xFF21D3ED),
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 2, color:  Color(0xFF21D3ED)),
                  insets: EdgeInsets.symmetric(horizontal: 0),
                ),
                tabs: categories.keys.map((e) => Tab(text: e)).toList(),
              ),
              backgroundColor: Color(0xFF0F172A),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Featured Section
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "Featured Styles",
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 160,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    autoPlayInterval: Duration(seconds: 2)
                  ),
                  items: featuredTemplates.map((imgPath) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>
                            CustomizationScreen(
                              category: 'Romantic', amount: '1000',
                              productType: 'Airtel Airtime',
                              pin: '1234567889990', templatePath: imgPath,)));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(imgPath, fit: BoxFit.cover, width: 300),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 10),

                // TabBarView for categories
                Expanded(
                  child: TabBarView(
                    children: categories.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                          ),
                          itemCount: entry.value.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                    CustomizationScreen(
                                        category: 'Romantic', amount: '1000',
                                      productType: 'Airtel Airtime',
                                      pin: '1234567889990', templatePath: entry.value[index],)));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: AssetImage(entry.value[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            ),
        );
    }
}