import 'package:atlantic_web3/atlantic_web3.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../helpers/sqlite3_helper.dart';

final class EthPassKeyModel extends BaseDocument {
  final String passkeyID;
  final Boolean isActive;
  final DateTime created;
  final DateTime updated;
  String name;
  final String privateKey;
  final String publicKey;
  Boolean isDefault;
  String? photoURL;

  EthPassKeyModel(
      this.passkeyID,
      this.isActive,
      this.created,
      this.updated,
      this.name,
      this.privateKey,
      this.publicKey,
      this.isDefault,
      this.photoURL);

  EthPassKeyModel.fromJson(Map<String, dynamic> json)
      : passkeyID = json['passkeyID'],
        isActive = Sqlite3Helper.sqliteToBoolean(json['isActive']),
        created = Sqlite3Helper.sqliteToDate(json['created']),
        updated = Sqlite3Helper.sqliteToDate(json['updated']),
        name = json['name'],
        privateKey = json['privateKey'],
        publicKey = json['publicKey'],
        isDefault = Sqlite3Helper.sqliteToBoolean(json['isDefault']),
        photoURL = json['photoURL'];

  @override
  List<dynamic> toListSave() => [
        passkeyID,
        Sqlite3Helper.booleanToSqlite(isActive),
        Sqlite3Helper.dateToSqlite(created),
        Sqlite3Helper.dateToSqlite(updated),
        name,
        privateKey,
        publicKey,
        Sqlite3Helper.booleanToSqlite(isDefault),
        photoURL
      ];

  @override
  List<dynamic> toListUpdate() => [
        Sqlite3Helper.booleanToSqlite(isActive),
        Sqlite3Helper.dateToSqlite(created),
        Sqlite3Helper.dateToSqlite(updated),
        name,
        privateKey,
        publicKey,
        Sqlite3Helper.booleanToSqlite(isDefault),
        photoURL,
        passkeyID
      ];

  @override
  String toString() {
    return 'EthPassKeyModel{'
        'passkeyID: $passkeyID, '
        'isActive: $isActive, '
        'created: $created, '
        'updated: $updated, '
        'name: $name, '
        'privateKey: $privateKey, '
        'publicKey: $publicKey, '
        'isDefault: $isDefault, '
        'photoURL: $photoURL}';
  }
}

abstract class KeyStore {
  Database? _instance;

  Future<Database> getDbConnection() async {
    if (_instance == null) {
      final docsDir = await getApplicationDocumentsDirectory();
      final filename = path.join(docsDir.path, 'my_demo_app.db');
      final db = sqlite3.open(filename);
      _createTable(db);

      _instance = db;
    }

    return _instance!;
  }

  void _createTable(Database db) {
    // Create a table and insert some data
    db.execute('''
        CREATE TABLE IF NOT EXISTS passkey (
          passkeyID VARCHAR(255) NOT NULL PRIMARY KEY,
          isActive BOOLEAN NOT NULL,
          created DATETIME NOT NULL,
          updated DATETIME NOT NULL,
          name VARCHAR(255) NOT NULL,
          privateKey TEXT NOT NULL,
          publicKey TEXT NOT NULL,
          isDefault BOOLEAN NOT NULL,
          photoURL VARCHAR(255) NULL
        );
      ''');
  }
}

abstract interface class IEthPassKeyStore {
  Future<EthPassKeyModel> create(EthPassKeyModel param);

  Future<EthPassKeyModel> update(EthPassKeyModel param);

  Future<Void> deleteAll();

  Future<EthPassKeyModel> findDefault();

  Future<EthPassKeyModel> findOne(String passkeyID);

  Future<List<EthPassKeyModel>> find();

  Future<Integer> exist(String passKeyID);
}

final class EthPassKeyStore extends KeyStore implements IEthPassKeyStore {
  @override
  Future<EthPassKeyModel> create(EthPassKeyModel param) async {
    // Get connection
    final Database db = await getDbConnection();

    // Create query
    const String query = '''
    INSERT INTO passkey (passkeyID, isActive, created, updated, name, privateKey,
        publicKey, isDefault, photoURL) VALUES (?,?,?,?,?,?,?,?,?)
    ''';

    // Prepare a statement to run it multiple times:
    db.prepare(query).execute(param.toListSave());

    // Create query
    const String query2 = '''
    SELECT * FROM passkey
        WHERE passkeyID = ? AND isActive = 1
    ''';

    // Get row inserted
    final ResultSet resultSet = db.prepare(query2).select([param.passkeyID]);

    // Get data
    final Row snapshot = resultSet[0];

    return EthPassKeyModel.fromJson(snapshot);
  }

  @override
  Future<EthPassKeyModel> update(EthPassKeyModel param) async {
    // Get connection
    final Database db = await getDbConnection();

    // Create query
    const String query = '''
    UPDATE passkey SET isActive = ?, created = ?, updated = ?, name = ?, privateKey = ?,
        publicKey = ?, isDefault = ?, photoURL = ? WHERE passkeyID = ?
    ''';

    // Prepare a statement to run it multiple times:
    db.prepare(query).execute(param.toListUpdate());

    // Create query
    const String query2 = '''
    SELECT * FROM passkey
        WHERE passkeyID = ? AND isActive = 1
    ''';

    // Get row inserted
    final ResultSet resultSet = db.prepare(query2).select([param.passkeyID]);

    // Get data
    final Row snapshot = resultSet[0];

    return EthPassKeyModel.fromJson(snapshot);
  }

  @override
  Future<Void> deleteAll() async {
    // Get connection
    final Database db = await getDbConnection();

    // Create query
    const String query = '''
    DELETE FROM passkey;
    VACUUM;
    ''';

    // Prepare a statement to run it multiple times:
    final delete = db.prepare(query).execute();

    return delete;
  }

  @override
  Future<EthPassKeyModel> findDefault() async {
    // Get connection
    final Database db = await getDbConnection();

    // Create query
    const String query = '''
    SELECT * FROM passkey WHERE
      isDefault = 1 AND isActive = 1
    ''';

    // Get row inserted
    final ResultSet resultSet = db.prepare(query).select();

    // Get data
    final Row snapshot = resultSet[0];

    return EthPassKeyModel.fromJson(snapshot);
  }

  @override
  Future<EthPassKeyModel> findOne(String passkeyID) async {
    // Get connection
    final Database db = await getDbConnection();

    // Create query
    const String query = '''
    SELECT * FROM passkey WHERE
      passkeyID = ? AND isActive = 1
    ''';

    // Get row inserted
    final ResultSet resultSet = db.prepare(query).select([passkeyID]);

    // Get data
    final Row snapshot = resultSet[0];

    return EthPassKeyModel.fromJson(snapshot);
  }

  @override
  Future<List<EthPassKeyModel>> find() async {
    // Get connection
    final Database db = await getDbConnection();

    // Create query
    const String query = '''
    SELECT * FROM passkey WHERE
      isActive = 1
    ''';

    // Get row inserted
    final ResultSet resultSet = db.prepare(query).select();

    // Get data
    final List<EthPassKeyModel> list = resultSet
        .map((snapshot) => EthPassKeyModel.fromJson(snapshot))
        .toList();

    return list;
  }

  @override
  Future<Integer> exist(String passKeyID) async {
    // Get connection
    final Database db = await getDbConnection();

    // Create query
    const String query = '''
    SELECT COUNT(*) FROM passkey WHERE
      passkeyID = ? AND isActive = 1
    ''';

    // Get row inserted
    final ResultSet resultSet = db.prepare(query).select([passKeyID]);

    // Get data
    final Row snapshot = resultSet[0];

    final Integer result = snapshot['COUNT(*)'];

    return result;
  }
}
