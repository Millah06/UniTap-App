import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:everywhere/constraints/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../screens/ai_messages.dart';

class CustomizationScreen extends StatefulWidget {
  final String category;
  final String templateColor;
  final String amount;
  final String productType; // Airtime or Data
  final String pin;
  final String templatePath;

  static String id = 'edit';

  const CustomizationScreen({
    super.key,
    required this.category,
    required this.amount,
    required this.productType,
    required this.pin,
    this.templateColor = "#F5F5F5",
    required this.templatePath,
  });

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {


  final GlobalKey _previewKey = GlobalKey();
  List<Color> _bgColor = [Color(0xFF6A11CB), Color(0xFF2575FC)];
  List<Color> _footer = [Color(0xFF21D3ED), Color(0xFF2575FC)];
  Color _textColor = Colors.white;
  final String _receiver = "RUQAYYA AMINU";
  final String _sender = "ABDULLAHI GARBA ALIYU";
  String _message = "Your custom message here";
  String _selectedFont = 'Dancing Script';

  int _selectedIndex = 0;

  bool _isReadOnly = true;
  final FocusNode focusNode = FocusNode();

  final List<String> _fonts = [
    'Dancing Script',
    'Roboto',
    'Poppins',
    'Montserrat',
  ];

  final List<List<Color>> bgData = [
    [Colors.black, Colors.white54],
    [Colors.red, Colors.green],
    [Colors.yellow, Colors.indigo],
    [Colors.purple, Colors.orange],
    [Colors.blue, Colors.white54],
    [Colors.pink, Colors.white54],
    [Colors.blueGrey, Colors.black]
  ];
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> colorSets = [
    // 1. Elegant Purple → Blue
    {
      "background": [Color(0xFF6A11CB), Color(0xFF2575FC)], // Purple → Blue
      "textColor": Colors.white,
      "footer": [Color(0xFF2575FC), Color(0xFF21D3ED), Color(0xFF2575FC)], // Matches icon & brand
    },
// 2. Deep Navy → Teal
    {
      "background": [Color(0xFF0F2027), Color(0xFF2C5364)],
      "textColor": Colors.white,
      "footer": [Color(0xFF38B2AC), Color(0xFF21D3ED), Color(0xFF38B2AC)],
    },
// 3. Sunset Vibe
    {
      "background": [Color(0xFFee9ca7), Color(0xFFffdde1)],
      "textColor": Color(0xFF1E293B), // Dark text for readability
      "footer": [Color(0xFF6EE7B7), Color(0xFF21D3ED), Color(0xFF6EE7B7)],
    },
// 4. Pink → Red Luxury
    {
      "background": [Color(0xFFFF416C), Color(0xFFFF4B2B)],
      "textColor": Colors.white,
      "footer": [Color(0xFFF43F5E), Color(0xFF21D3ED), Color(0xFFF43F5E)],
    },
// 5. Emerald Green
    {
      "background": [Color(0xFF11998e), Color(0xFF38ef7d)],
      "textColor": Colors.white,
      "footer": [Color(0xFF21D3ED), Color(0xFF34D399)],
    },
// 6. Golden Sunrise
    {
      "background": [Color(0xFFFFD194), Color(0xFFD1913C)],
      "textColor": Color(0xFF1F2937),
      "footer": [Color(0xFF21D3ED), Color(0xFFF59E0B)],
    },
// 7. Dark Lava
    {
      "background": [Color(0xFF232526), Color(0xFF414345)],
      "textColor": Colors.white,
      "footer": [Color(0xFF21D3ED), Color(0xFF4B5563)],
    },
// 8. Ocean Breeze
    {
      "background": [Color(0xFF2BC0E4), Color(0xFFEAECC6)],
      "textColor": Color(0xFF1E293B),
      "footer": [Color(0xFF21D3ED), Color(0xFF60A5FA)],
    },
// 9. Royal Gold → Deep Blue
    {
      "background": [Color(0xFFF7971E), Color(0xFFFFD200)],
      "textColor": Color(0xFF111827),
      "footer": [Color(0xFF21D3ED), Color(0xFF1D4ED8)],
    },
// 10. Frosted Mint
    {
      "background": [Color(0xFFc2e59c), Color(0xFF64b3f4)],
      "textColor": Color(0xFF1F2937),
      "footer": [Color(0xFF21D3ED), Color(0xFF3B82F6)],
    },
// 11. Crimson Night
    {
      "background": [Color(0xFF780206), Color(0xFF061161)],
      "textColor": Colors.white,
      "footer": [Color(0xFF21D3ED), Color(0xFF9333EA)],
    },
// 12. Rose Quartz
    {
      "background": [Color(0xFFeecda3), Color(0xFFef629f)],
      "textColor": Color(0xFF1E293B),
      "footer": [Color(0xFF21D3ED), Color(0xFFEC4899)],
    },
// 13. Silver Mist
    {
      "background": [Color(0xFFBDC3C7), Color(0xFF2C3E50)],
      "textColor": Colors.white,
      "footer": [Color(0xFF21D3ED), Color(0xFF64748B)],
    },
// 14. Sapphire Dream
    {
      "background": [Color(0xFF0f0c29), Color(0xFF302b63)],
      "textColor": Colors.white,
      "footer": [Color(0xFF21D3ED), Color(0xFF2563EB)],
    },
  ];

  final List<Map<String, dynamic>> colorSet = [
    // 1. Luxury Purple → Magenta | Footer: Electric Cyan → Deep Indigo
    {
      "background": [Color(0xFF6D28D9), Color(0xFFD946EF)],
      "textColor": Colors.white,
      "footer": [Color(0xFF21D3ED), Color(0xFF312E81)],
    },
    // 2. Aqua Blue → Teal | Footer: Bold Pink → Purple
    {
      "background": [Color(0xFF06B6D4), Color(0xFF10B981)],
      "textColor": Colors.white,
      "footer": [Color(0xFFEC4899), Color(0xFF7C3AED)],
    },
    // 3. Sunset Orange → Peach | Footer: Brand Cyan → Deep Navy
    {
      "background": [Color(0xFFF97316), Color(0xFFFBBF24)],
      "textColor": Color(0xFF1F2937),
      "footer": [Color(0xFF21D3ED), Color(0xFF1E3A8A)],
    },
    // 4. Royal Blue → Sky | Footer: Warm Gold → Dark Amber
    {
      "background": [Color(0xFF2563EB), Color(0xFF3B82F6)],
      "textColor": Colors.white,
      "footer": [Color(0xFFFACC15), Color(0xFFB45309)],
    },
    // 5. Deep Pink → Rose | Footer: Neon Green → Brand Cyan
    {
      "background": [Color(0xFFBE185D), Color(0xFFDB2777)],
      "textColor": Colors.white,
      "footer": [Color(0xFF22C55E), Color(0xFF21D3ED)],
    },
    // 6. Emerald Green → Mint | Footer: Bold Coral → Crimson
    {
      "background": [Color(0xFF065F46), Color(0xFF10B981)],
      "textColor": Colors.white,
      "footer": [Color(0xFFFB7185), Color(0xFFBE123C)],
    },
    // 7. Vibrant Cyan → Electric Blue | Footer: Violet → Magenta
    {
      "background": [Color(0xFF0891B2), Color(0xFF0EA5E9)],
      "textColor": Colors.white,
      "footer": [Color(0xFF9333EA), Color(0xFFD946EF)],
    },
    // 8. Soft Lavender → Pink | Footer: Dark Navy → Brand Cyan
    {
      "background": [Color(0xFF818CF8), Color(0xFFF0ABFC)],
      "textColor": Color(0xFF1F2937),
      "footer": [Color(0xFF1E3A8A), Color(0xFF21D3ED)],
    },
    // 9. Golden Yellow → Orange | Footer: Royal Blue → Indigo
    {
      "background": [Color(0xFFF59E0B), Color(0xFFF97316)],
      "textColor": Colors.white,
      "footer": [Color(0xFF1E40AF), Color(0xFF312E81)],
    },
    // 10. Fresh Lime → Bright Green | Footer: Hot Pink → Deep Purple
    {
      "background": [Color(0xFFA3E635), Color(0xFF65A30D)],
      "textColor": Color(0xFF111827),
      "footer": [Color(0xFFF472B6), Color(0xFF7E22CE)],
    },
    // 11. Crimson Red → Burgundy | Footer: Brand Cyan → Cool Gray
    {
      "background": [Color(0xFF991B1B), Color(0xFF7F1D1D)],
      "textColor": Colors.white,
      "footer": [Color(0xFF21D3ED), Color(0xFF374151)],
    },
    // 12. Ocean Blue → Aqua Mint | Footer: Bold Orange → Amber
    {
      "background": [Color(0xFF0EA5E9), Color(0xFF14B8A6)],
      "textColor": Colors.white,
      "footer": [Color(0xFFF97316), Color(0xFFB45309)],
    },
    // 13. Peach → Soft Coral | Footer: Deep Indigo → Brand Cyan
    {
      "background": [Color(0xFFFBCFE8), Color(0xFFF87171)],
      "textColor": Color(0xFF1E293B),
      "footer": [Color(0xFF312E81), Color(0xFF21D3ED)],
    },
    // 14. Midnight Blue → Deep Purple | Footer: Gold → Bright Orange
    {
      "background": [Color(0xFF1E3A8A), Color(0xFF4C1D95)],
      "textColor": Colors.white,
      "footer": [Color(0xFFF59E0B), Color(0xFFF97316)],
    },
  ];


  void _suggestMessage() {
    final suggestions = messageSuggestions[widget.category];
    if (suggestions != null && suggestions.isNotEmpty) {
      setState(() {
        _controller.text = (suggestions..shuffle()).first;
      });
    }
  }

  Future<void> _generateAndShareImage() async {
    try {
      RenderRepaintBoundary boundary =
      _previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0); // High quality
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to temporary directory
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/gift_card.png';
      File imgFile = File(filePath);
      await imgFile.writeAsBytes(pngBytes);

      // // Share the image
      // await Share.shareFiles([filePath], text: "Here’s your surprise gift! ❤️");

      await SharePlus.instance.share(
        ShareParams(
            files:  [XFile(filePath)],
            title: 'Smart Spend Pdf Expense Report',
            text: 'Here’s your surprise gift! ❤️'
        ),
      );

    } catch (e) {
      print("Error generating image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong. Try again!')),
      );
    }
  }

  @override
  void initState() {
    _suggestMessage();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final String templatePath = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Customize Gift Card'),
        // backgroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RepaintBoundary(
              key: _previewKey,
              child: Container(
                margin: EdgeInsetsGeometry.only(left: 10,
                    right: 10, top: 0, bottom: 6),
                padding: EdgeInsetsGeometry.only(left: 20,
                    right: 20, top: 10, bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.orange,
                  image: DecorationImage(fit: BoxFit.cover,
                      image: AssetImage(widget.templatePath)),
                ),
                child: TextFieldTapRegion(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  onTapInside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Container(
                      width: 350,
                      height: 410,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                          gradient: LinearGradient(colors:
                          _bgColor)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          Text("To: $_receiver",
                              style: GoogleFonts.poppins(fontSize: 14, color: _textColor)),
                          Text("$kNaira${kFormatter.format(widget.amount)}",
                              style: GoogleFonts.poppins(
                                  fontSize: 36, fontWeight: FontWeight.bold, color: _textColor)),
                          Text(widget.productType,
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.w500, color: _textColor)),
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                          //   child: Text(
                          //     _message,
                          //     textAlign: TextAlign.center,
                          //     style: GoogleFonts.getFont(_selectedFont,
                          //         fontSize: 16, fontWeight: FontWeight.bold, color: _textColor),
                          //   ),
                          // ),
                          GestureDetector(
                            onTap: () {
                              if (_isReadOnly) {
                                setState(() {
                                  _isReadOnly = false;
                                });
                                FocusScope.of(context).requestFocus(focusNode);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                              child: TextField(
                                controller: _controller,
                                autofocus: true,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                readOnly: false,
                                focusNode: focusNode,
                                cursorColor: Colors.white,
                                showCursor: true,
                                style: GoogleFonts.getFont(_selectedFont,
                                          fontSize: 16, fontWeight: FontWeight.bold, color: _textColor),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                              
                                ),
                              ),
                            ),
                          ),
                          Text("PIN: ${widget.pin}",
                              style: GoogleFonts.robotoMono(fontSize: 18, color: _textColor)),
                          SizedBox(height: 10,),
                          Text("From: $_sender",
                              style: GoogleFonts.poppins(fontSize: 14, color: _textColor)),
                          SizedBox(height: 10,),
                          CustomPaint(
                            size: Size(300, 80),
                            painter: FooterPainter(
                              // begin: _beginAnimation.value,
                              // end: _endAnimation.value,
                              footerBG: _footer,
                            ),
                            child: Center(
                              child: Container(
                                width: 350,
                                height: 80,
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset("images/eraser.png", height: 30),
                                    SizedBox(width: 8),
                                    Text("Made with Elite Pay",
                                        style: GoogleFonts.poppins(
                                            fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Controls
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text("Backgrounds", style: GoogleFonts.inter(
                        fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: _suggestMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kButtonColor,
                      ),
                      child: Row(
                        children: [
                          Text("Suggest Message", style: TextStyle(color: Color(0xFF111827)),),
                          SizedBox(width: 5,),
                          Icon(FontAwesomeIcons.diceD6, color: Colors.black,)
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),
                SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 20
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      List<Color> currentBGColor = colorSet[index]['background'];
                      Color currentTextColor = colorSet[index]['textColor'];
                      List<Color> footerBGColor = colorSet[index]['footer'];
                      bool isSelected = _selectedIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                             _selectedIndex = index;
                            // isSelected != isSelected;
                            _bgColor = currentBGColor;
                            _textColor = currentTextColor;
                            _footer = footerBGColor;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white54,
                              border: isSelected ?Border.all(
                                  color: Colors.white54
                              ) : Border(),
                              gradient: LinearGradient(
                                  colors: currentBGColor
                              )
                          ),
                          child: Center(
                            child: isSelected? Icon(Icons.check) : Container(),
                          ),
                        ),
                      );
                    },
                    itemCount: colorSets.length,
                  ),
                ),
                SizedBox(height: 10),

                SizedBox(height: 10),

                DropdownButton<String>(
                  dropdownColor: Colors.black,
                  value: _selectedFont,
                  items: _fonts
                      .map((f) => DropdownMenuItem(value: f, child: Text(f,
                    style: GoogleFonts.getFont(f, color: Colors.white, ),)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedFont = val!),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _generateAndShareImage,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kButtonColor
                  ),
                  child: Text("Generate & Share", style: TextStyle(color: Color(0xFF111827)),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class FooterPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = kButtonColor;
//     final path = Path()
//       ..lineTo(0, size.height - 30)
//       ..quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 30)
//       ..lineTo(size.width, 0)
//       ..close();
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

class FooterPainter extends CustomPainter {
  // final Alignment begin;
  // final Alignment end;
  final List<Color> footerBG;

  FooterPainter({required this.footerBG});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Gradient gradient = LinearGradient(
      colors:  footerBG,
      // begin: begin,
      // end: end,
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    final path = Path()
      ..lineTo(0, size.height - 30)
      ..quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 30)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant FooterPainter oldDelegate) => true;
}