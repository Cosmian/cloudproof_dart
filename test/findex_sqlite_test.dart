import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloudproof/cloudproof.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

const expectedUsersIdsForFrance = [
  4,
  5,
  7,
  8,
  14,
  17,
  19,
  20,
  23,
  34,
  37,
  43,
  46,
  48,
  55,
  56,
  60,
  61,
  63,
  65,
  68,
  70,
  71,
  77,
  80,
  82,
  83,
  85,
  86,
  96
];

void main() {
  group('Findex SQLite', () {
    test('search/upsert', () async {
      await initDb();

      final masterKeys = FindexMasterKeys.fromJson(jsonDecode(
          await File('test/resources/findex/master_keys.json').readAsString()));

      final label = Uint8List.fromList(utf8.encode("Some Label"));

      expect(SqliteFindex.count('entry_table'), equals(0));
      expect(SqliteFindex.count('chain_table'), equals(0));

      await SqliteFindex.indexAll(masterKeys, label);

      expect(SqliteFindex.count('entry_table'), equals(583));
      expect(SqliteFindex.count('chain_table'), equals(800));

      final indexedValues = await SqliteFindex.search(
          masterKeys.k, label, [Word.fromString("France")]);

      final usersIds = indexedValues.map((indexedValue) {
        return indexedValue.location.bytes[0];
      }).toList();
      usersIds.sort();

      expect(usersIds, equals(expectedUsersIdsForFrance));
    });
  });
}

String dbPath() {
  return path.join(Directory.systemTemp.path, "findex_tests.database");
}

Future<Database> initDb() async {
  if (await File(dbPath()).exists()) {
    await File(dbPath()).delete();
  }
  final db = sqlite3.open(dbPath());

  db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id integer PRIMARY KEY,
      firstName text NOT NULL,
      lastName text NOT NULL,
      email text NOT NULL,
      phone text NOT NULL,
      country text NOT NULL,
      region text NOT NULL,
      employeeNumber text NOT NULL,
      security text NOT NULL
    )
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS entry_table (uid BLOB PRIMARY KEY,value BLOB NOT NULL)
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS chain_table (uid BLOB PRIMARY KEY,value BLOB NOT NULL)
  ''');

  final users =
      jsonDecode(await File('test/resources/findex/users.json').readAsString());

  final stmt = db.prepare(
      'INSERT INTO users (id, firstName, lastName, phone, email, country, region, employeeNumber, security) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)');
  for (final user in users) {
    stmt.execute([
      user['id'],
      user['firstName'],
      user['lastName'],
      user['phone'],
      user['email'],
      user['country'],
      user['region'],
      user['employeeNumber'],
      user['security'],
    ]);
  }

  return db;
}

class SqliteFindex {
  static Database? singletonDb;

  static Database get db {
    if (singletonDb != null) {
      return singletonDb as Database;
    }

    final newDb = sqlite3.open(dbPath());
    singletonDb = newDb;
    return newDb;
  }

  static Future<void> indexAll(
      FindexMasterKeys masterKeys, Uint8List label) async {
    final users = allUsers();

    final indexedValuesAndWords = {
      for (final user in users)
        IndexedValue.fromLocation(user.location): user.indexedWords,
    };

    await upsert(masterKeys, label, indexedValuesAndWords);
  }

  static List<User> allUsers() {
    final ResultSet resultSet = db.select('SELECT * FROM users');
    List<User> users = [];

    for (final Row row in resultSet) {
      users.add(User.fromMap(row));
    }

    return users;
  }

  static int count(String table) {
    final ResultSet resultSet = db.select('SELECT COUNT(*) FROM $table');

    return int.parse(resultSet.first.values.first.toString());
  }

  static Map<Uint8List, Uint8List> fetchEntries(List<Uint8List> uids) {
    var questions = ("?," * uids.length);
    questions = questions.substring(0, questions.length - 1);

    final ResultSet resultSet =
        db.select('SELECT * FROM entry_table WHERE uid IN ($questions)', uids);
    Map<Uint8List, Uint8List> entries = {};

    for (final Row row in resultSet) {
      entries[row['uid']] = row['value'];
    }

    return entries;
  }

  static Map<Uint8List, Uint8List> fetchChains(List<Uint8List> uids) {
    var questions = ("?," * uids.length);
    questions = questions.substring(0, questions.length - 1);

    final ResultSet resultSet =
        db.select('SELECT * FROM chain_table WHERE uid IN ($questions)', uids);
    Map<Uint8List, Uint8List> entries = {};

    for (final Row row in resultSet) {
      entries[row['uid']] = row['value'];
    }

    return entries;
  }

  static void upsertEntries(Map<Uint8List, Uint8List> entries) {
    final stmt = db.prepare(
        'INSERT OR REPLACE INTO entry_table (uid, value) VALUES (?, ?)');
    for (final entry in entries.entries) {
      stmt.execute([
        entry.key,
        entry.value,
      ]);
    }
  }

  static void upsertChains(Map<Uint8List, Uint8List> chains) {
    final stmt = db.prepare(
        'INSERT OR REPLACE INTO chain_table (uid, value) VALUES (?, ?)');
    for (final chain in chains.entries) {
      stmt.execute([
        chain.key,
        chain.value,
      ]);
    }
  }

  // --------------------------------------------------
  // Copy-paste code :AutoGeneratedImplementation
  // --------------------------------------------------

  static Future<List<IndexedValue>> search(
    Uint8List keyK,
    Uint8List label,
    List<Word> words,
  ) async {
    return await Findex.search(
      keyK,
      label,
      words,
      Pointer.fromFunction(
        fetchEntriesCallback,
        errorCodeInCaseOfCallbackException,
      ),
      Pointer.fromFunction(
        fetchChainsCallback,
        errorCodeInCaseOfCallbackException,
      ),
    );
  }

  static Future<void> upsert(
    FindexMasterKeys masterKeys,
    Uint8List label,
    Map<IndexedValue, List<Word>> indexedValuesAndWords,
  ) async {
    await Findex.upsert(
      masterKeys,
      label,
      indexedValuesAndWords,
      Pointer.fromFunction(
        fetchEntriesCallback,
        errorCodeInCaseOfCallbackException,
      ),
      Pointer.fromFunction(
        upsertEntriesCallback,
      ),
      Pointer.fromFunction(
        upsertChainsCallback,
      ),
    );
  }

  static int fetchEntriesCallback(
    Pointer<Char> outputPointer,
    Pointer<UnsignedInt> outputLength,
    Pointer<UnsignedChar> entriesUidsListPointer,
    int entriesUidsListLength,
  ) {
    return Findex.fetchWrapperWithoutIsolate(
      outputPointer,
      outputLength,
      entriesUidsListPointer,
      entriesUidsListLength,
      SqliteFindex.fetchEntries,
    );
  }

  static int fetchChainsCallback(
    Pointer<Char> outputPointer,
    Pointer<UnsignedInt> outputLength,
    Pointer<UnsignedChar> chainsUidsListPointer,
    int chainsUidsListLength,
  ) {
    return Findex.fetchWrapperWithoutIsolate(
      outputPointer,
      outputLength,
      chainsUidsListPointer,
      chainsUidsListLength,
      SqliteFindex.fetchChains,
    );
  }

  static void upsertEntriesCallback(
    Pointer<UnsignedChar> entriesListPointer,
    int entriesListLength,
  ) {
    return Findex.upsertWrapperWithoutIsolate(
      entriesListPointer,
      entriesListLength,
      SqliteFindex.upsertEntries,
    );
  }

  static void upsertChainsCallback(
    Pointer<UnsignedChar> chainsListPointer,
    int chainsListLength,
  ) {
    return Findex.upsertWrapperWithoutIsolate(
      chainsListPointer,
      chainsListLength,
      SqliteFindex.upsertChains,
    );
  }
}

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String country;
  final String region;
  final String employeeNumber;
  final String security;

  User(this.id, this.firstName, this.lastName, this.phone, this.email,
      this.country, this.region, this.employeeNumber, this.security);

  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      json['id'],
      json['firstName'],
      json['lastName'],
      json['phone'],
      json['email'],
      json['country'],
      json['region'],
      json['employeeNumber'],
      json['security'],
    );
  }

  Location get location {
    return Location(Uint8List.fromList([id]));
  }

  List<Word> get indexedWords {
    return [
      Word.fromString(firstName),
      Word.fromString(lastName),
      Word.fromString(phone),
      Word.fromString(email),
      Word.fromString(country),
      Word.fromString(region),
      Word.fromString(employeeNumber),
      Word.fromString(security)
    ];
  }
}
