import 'package:flutter/material.dart';

import '../constraints/constants.dart';

class ServiceFrame extends StatelessWidget {

  const ServiceFrame({super.key, required this.title, required this.icon, required this.onTap});

  final String title;
  final Icon icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Card(
              color: Color(0xFF177E85),
              elevation: 4,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF177E85),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Color(0xFF177E85).withOpacity(0.4),
                      blurRadius: 8, spreadRadius: 1, offset: Offset(0, 4))]
                ),
                child: icon,
              ),
            ),
          ),
          SizedBox(height: 9,),
          Text(title,
            style: kTitle.copyWith(color: Colors.white70, fontFamily: 'DejaVu Sans' ), textAlign: TextAlign.center,)
        ],
      ),
    );
  }
}
