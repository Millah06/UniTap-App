
import 'package:hive/hive.dart';
part 'cable_beneficiary_model.g.dart';


@HiveType(typeId: 0)
class CableBeneficiaryModel extends HiveObject {
  @HiveField(0)
  String smartCardNumber;

  @HiveField(1)
  String beneficiaryName;

  @HiveField(2)
  String status;

  @HiveField(3)
  String providerName;

  @HiveField(4)
  DateTime date;

  CableBeneficiaryModel({
    required this.smartCardNumber,
    required this.beneficiaryName,
    required this.status,
    required this.providerName,
    required this.date,
  });
}