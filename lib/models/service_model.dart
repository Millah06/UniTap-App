import 'package:flutter/cupertino.dart';

class ServiceModel {
  bool ? isNew;
  String name;
  IconData icon;
  Function() function;

  ServiceModel({required this.name, required this.icon, required this.function, this.isNew});
}