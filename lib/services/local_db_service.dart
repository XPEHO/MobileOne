import 'package:MobileOne/dao/local_db_dao.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class LocalDbService {
  final LocalDbDao dao = GetIt.I.get<LocalDbDao>();
  Database db;

  Future<void> initDb() async {
    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    var dbPath = join(dir.path, 'local.db');
    db = await databaseFactoryIo.openDatabase(dbPath);
  }

  Future<void> storeRecord(StoreRef ref, String key, dynamic value) async {
    await dao.storeRecord(db, ref, key, value);
  }

  Future<dynamic> getRecord(StoreRef ref, String key) async {
    return await dao.getRecord(db, ref, key);
  }

  Future<dynamic> findRecord(StoreRef ref, String key, String pattern) async {
    return await dao.findRecord(db, ref, key, pattern);
  }
}
