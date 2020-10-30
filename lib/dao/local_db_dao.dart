import 'package:sembast/sembast.dart';

class LocalDbDao {
  Future<void> storeRecord(
      Database db, StoreRef ref, String key, dynamic value) async {
    await ref.record(key).put(db, value);
  }

  Future<dynamic> getRecord(Database db, StoreRef ref, String key) async {
    return ref.record(key).get(db);
  }

  Future<dynamic> findRecord(
      Database db, StoreRef ref, String key, String pattern) async {
    return ref.find(db, finder: Finder(filter: Filter.matches(key, pattern)));
  }
}
