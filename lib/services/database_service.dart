import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/follow.dart';
import '../models/user.dart';
import '../models/visit_record.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Isar? _isar;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<Isar> get isar async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }
    _isar = await init();
    return _isar!;
  }

  static Future<Isar> init() async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }
    final existing = Isar.getInstance();
    if (existing != null && existing.isOpen) {
      _isar = existing;
      return _isar!;
    }
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [VisitRecordSchema, UserSchema, FollowSchema],
      directory: dir.path,
    );
    return _isar!;
  }

  /// Get all visit records sorted by timestamp descending
  Future<List<VisitRecord>> getAllVisits() async {
    final db = await isar;
    return await db.visitRecords.where().sortByTimestampDesc().findAll();
  }

  /// Watch all visit records as a stream
  Stream<List<VisitRecord>> watchVisits() async* {
    final db = await isar;
    yield* db.visitRecords.where().sortByTimestampDesc().watch(fireImmediately: true);
  }

  /// Get visit by UUID
  Future<VisitRecord?> getVisitByUuid(String uuid) async {
    final db = await isar;
    return await db.visitRecords.filter().uuidEqualTo(uuid).findFirst();
  }

  /// Save (insert or update) visit record
  Future<void> saveVisit(VisitRecord visit) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.visitRecords.put(visit);
    });
  }

  /// Delete visit record by UUID
  Future<bool> deleteVisit(String uuid) async {
    final db = await isar;
    return await db.writeTxn(() async {
      final record = await db.visitRecords.filter().uuidEqualTo(uuid).findFirst();
      if (record != null) {
        return await db.visitRecords.delete(record.id);
      }
      return false;
    });
  }
}
