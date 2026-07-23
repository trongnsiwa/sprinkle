import 'package:isar/isar.dart';

part 'visit_record.g.dart';

@collection
class VisitRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String name;
  String? notes;
  double rating = 0.0;
  late DateTime timestamp;
  String? imageFileName;
  String? address;
  double? latitude;
  double? longitude;
  List<String> tags = [];
}
