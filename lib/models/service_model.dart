import 'package:flutter/cupertino.dart';

class ServiceModel {
  String name;
  Icon icon;
  Function() function;

  ServiceModel({required this.name, required this.icon, required this.function});
}