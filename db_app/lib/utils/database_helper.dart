import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/contact.dart';

class DatabaseHelper {
  static const dbName = 'Contact.db';
  static const dbVersion = 1;

  DatabaseHelper._pr();

  static final DatabaseHelper instance = DatabaseHelper._pr();
  Database _db;

  Future<Database> get database async {
    if (_db != null) return _db;
    _db = await _initDatabase();
    return _db;
  }

  _initDatabase() async {
    Directory dataDir = await getApplicationDocumentsDirectory();
    String dbPath = join(dataDir.path, dbName);
    return await openDatabase(dbPath,
        version: dbVersion, onCreate: _onCreateDb);
  }

  _onCreateDb(Database db, int version) async {
    await db.execute('''
    Create Table ${Contact.tblContact}(
      ${Contact.tblId} Integer Primary key Autoincrement,
      ${Contact.tblName} Text Not Null ,
      ${Contact.tblNumber} Text Not Null

    )
    
    ''');
  }

  Future<int> insertContact(Contact cont) async {
    Database db = await database;
    return await db.insert(Contact.tblContact, cont.toMap());
  }

  Future<int> updateContact(Contact cont) async {
    Database db = await database;
    return await db.update(Contact.tblContact, cont.toMap(),
        where: '${Contact.tblId}=?', whereArgs: [cont.id]);
  }

  Future<int> deleteContact(int id) async {
    Database db = await database;
    return await db.delete(Contact.tblContact,
        where: '${Contact.tblId}=?', whereArgs: [id]);
  }

  Future<List<Contact>> fetchContact() async {
    Database db = await database;
    List<Map> contact = await db.query(Contact.tblContact);
    return contact.length == 0
        ? []
        : contact.map((Map) => Contact.fromMap(Map)).toList();
  }
}
