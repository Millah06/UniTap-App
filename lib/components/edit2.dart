import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  static String id = 'edit';

  const CustomizationScreen({
    super.key,
    required this.category,
    required this.amount,
    required this.productType,
    required this.pin,
    this.templateColor = "#F5F5F5",
  });

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {


  final GlobalKey _previewKey = GlobalKey();
  Color _bgColor = Colors.white;
  final String _receiver = "Receiver Name";
  final String _sender = "Sender Name";
  String _message = "Your custom message here";
  String _selectedFont = 'Roboto';

  final List<String> _fonts = [
    'Roboto',
    'Poppins',
    'Dancing Script',
    'Montserrat',
  ];

  void _suggestMessage() {
    final suggestions = messageSuggestions[widget.category];
    if (suggestions != null && suggestions.isNotEmpty) {
      setState(() {
        _message = (suggestions..shuffle()).first;
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
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Customize Gift Card'),
        // backgroundColor: Colors.black,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: RepaintBoundary(
                  key: _previewKey,
                  child: Container(

                    padding: EdgeInsetsGeometry.only(left: 20,
                        right: 20, top: 15, bottom: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange,
                      image: DecorationImage(fit: BoxFit.cover,
                          image: AssetImage('images/birthday/photo6.jpeg')),
                    ),
                    child: Card(
                      elevation: 8,
                      child: Container(
                        width: 350,
                        height: 500,
                        decoration: BoxDecoration(
                          color: _bgColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 20),
                            Text("To: $_receiver",
                                style: GoogleFonts.poppins(fontSize: 14)),
                            Text("${widget.amount}",
                                style: GoogleFonts.poppins(
                                    fontSize: 36, fontWeight: FontWeight.bold)),
                            Text(widget.productType,
                                style: GoogleFonts.poppins(
                                    fontSize: 18, fontWeight: FontWeight.w500)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                _message,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.getFont(_selectedFont,
                                    fontSize: 16),
                              ),
                            ),
                            Text("PIN: ${widget.pin}",
                                style: GoogleFonts.robotoMono(fontSize: 18)),
                            Text("From: $_sender",
                                style: GoogleFonts.poppins(fontSize: 14)),
                            CustomPaint(
                              size: Size(350, 80),
                              painter: FooterPainter(),
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
                                            fontSize: 14, color: Colors.white)),
                                  ],
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
          ),
          // Controls
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _suggestMessage,
                  child: Text("Suggest Message"),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Background:"),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _bgColor = Colors.blue[100]!);
                      },
                      child: Text("Blue"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _bgColor = Colors.pink[100]!);
                      },
                      child: Text("Pink"),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: _selectedFont,
                  items: _fonts
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedFont = val!),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _generateAndShareImage,
                  child: Text("Generate & Share"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FooterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.deepPurple;
    final path = Path()
      ..lineTo(0, size.height - 30)
      ..quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 30)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}