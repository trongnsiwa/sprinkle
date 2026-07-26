import 'package:isar/isar.dart';

part 'follow.g.dart';

@collection
class Follow {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String followerId;

  @Index()
  late String followeeId;

  late DateTime createdAt;
}
