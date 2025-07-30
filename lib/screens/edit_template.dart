// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
//
// import 'dart:typed_data';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
//
// class Sticker {
//   String assetPath;
//   double x;
//   double y;
//
//   Sticker(this.assetPath, this.x, this.y);
// }
//
//
// class CustomizationScreen extends StatefulWidget {
//
//   static String id = 'edit';
//   @override
//   _CustomizationScreenState createState() => _CustomizationScreenState();
// }
//
// class _CustomizationScreenState extends State<CustomizationScreen> {
//   GlobalKey _previewKey = GlobalKey();
//
//
//
//   String toText = "To: Your Love ❤️";
//   String fromText = "From: Me 😘";
//   String messageText = "Enjoy this data gift, stay connected!";
//
//   List<Sticker> _stickers = [];
//
//   Color textColor = Colors.white;
//   String selectedFont = 'Lobster'; // Default romantic font
//
//   @override
//   Widget build(BuildContext context) {
//     final String templatePath =
//     ModalRoute.of(context)!.settings.arguments as String;
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text('Customize Your Gift'),
//         backgroundColor: Colors.black,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Preview Area
//             RepaintBoundary(
//               key: _previewKey,
//               child: Container(
//                 width: double.infinity,
//                 height: 400,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(templatePath),
//                     fit: BoxFit.cover,
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(toText,
//                           style: GoogleFonts.getFont(
//                             selectedFont,
//                             color: textColor,
//                             fontSize: 22,
//                           )),
//                       Spacer(),
//                       Text(messageText,
//                           style: GoogleFonts.getFont(
//                             selectedFont,
//                             color: textColor,
//                             fontSize: 18,
//                           )),
//                       Spacer(),
//                       Text(fromText,
//                           style: GoogleFonts.getFont(
//                             selectedFont,
//                             color: textColor,
//                             fontSize: 20,
//                           )),
//                       ..._stickers.asMap().entries.map((entry) {
//                         int index = entry.key;
//                         Sticker sticker = entry.value;
//                         return Positioned(
//                           left: sticker.x,
//                           top: sticker.y,
//                           child: GestureDetector(
//                             onPanUpdate: (details) {
//                               setState(() {
//                                 sticker.x += details.delta.dx;
//                                 sticker.y += details.delta.dy;
//                               });
//                             },
//                             onLongPress: () {
//                               // Show delete option
//                               showDialog(
//                                 context: context,
//                                 builder: (_) => AlertDialog(
//                                   title: Text('Remove Sticker?'),
//                                   actions: [
//                                     TextButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           _stickers.removeAt(index);
//                                         });
//                                         Navigator.pop(context);
//                                       },
//                                       child: Text('Delete'),
//                                     ),
//                                     TextButton(
//                                       onPressed: () => Navigator.pop(context),
//                                       child: Text('Cancel'),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                             child: Image.asset(sticker.assetPath, width: 50),
//                           ),
//                         );
//                       }),
//
//
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//
//             // Input Fields
//             TextField(
//               style: TextStyle(color: Colors.white),
//               decoration: InputDecoration(labelText: "To", labelStyle: TextStyle(color: Colors.white)),
//               onChanged: (val) => setState(() => toText = "To: $val"),
//             ),
//             TextField(
//               style: TextStyle(color: Colors.white),
//               decoration: InputDecoration(labelText: "Message", labelStyle: TextStyle(color: Colors.white)),
//               onChanged: (val) => setState(() => messageText = val),
//             ),
//             TextField(
//               style: TextStyle(color: Colors.white),
//               decoration: InputDecoration(labelText: "From", labelStyle: TextStyle(color: Colors.white)),
//               onChanged: (val) => setState(() => fromText = "From: $val"),
//             ),
//
//             SizedBox(height: 15),
//
//             // Color Picker
//             ElevatedButton(
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: Text("Pick Text Color"),
//                     content: BlockPicker(
//                       pickerColor: textColor,
//                       onColorChanged: (color) {
//                         setState(() => textColor = color);
//                         Navigator.pop(context);
//                       },
//                     ),
//                   ),
//                 );
//               },
//               child: Text("Pick Text Color"),
//             ),
//
//             SizedBox(height: 10),
//
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 // // _buildStickerButton('assets/stickers/heart.png'),
//                 // _buildStickerButton('assets/stickers/balloon.png'),
//                 // _buildStickerButton('assets/stickers/gift.png'),
//                 _buildStickerButton('images/ai.png'),
//                 _buildStickerButton('images/ai.png'),
//                 _buildStickerButton('images/ai.png'),
//               ],
//             ),
//           ),
//
//
//
//
//       // Font Selector (basic example)
//             DropdownButton<String>(
//               value: selectedFont,
//               dropdownColor: Colors.black,
//               style: TextStyle(color: Colors.white),
//               items: ['Lobster', 'Pacifico', 'Dancing Script'].map((font) {
//                 return DropdownMenuItem(
//                   value: font,
//                   child: Text(font, style: GoogleFonts.getFont(font, color: Colors.white)),
//                 );
//               }).toList(),
//               onChanged: (value) => setState(() => selectedFont = value!),
//             ),
//
//             SizedBox(height: 20),
//
//             ElevatedButton(
//               onPressed: _generateAndShareImage,
//               child: Text("Generate & Share"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStickerButton(String path) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _stickers.add(Sticker(path, 100, 100)); // Default position
//         });
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Image.asset(path, width: 40),
//       ),
//     );
//   }
//
//
//
//
// }
