import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String name;
  String avatar = '✨';
  String? bio;
  late DateTime createdAt;

  @Index()
  bool isCurrentUser = false;
}
