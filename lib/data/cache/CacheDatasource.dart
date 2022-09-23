import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../model/Field.dart';

class CacheDatasource{

  Future<Database> _fetchDatabase() async {
    if(Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'fields_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE Field (guid TEXT NOT NULL,name TEXT NOT NULL,region TEXT NOT NULL,subdivisionGuid TEXT NOT NULL)',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    return database;
  }

  Future<void> insertFields(List<Field> fields) async {
    // Get a reference to the database.
    final db = await _fetchDatabase();

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    fields.forEach((element) async {
      await db.insert(
        'Field',
        element.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<List<Field>> getSavedFields() async {
    // Get a reference to the database.
    final db = await _fetchDatabase();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('Field');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Field(
          guid: maps[i]['guid'],
          name: maps[i]['name'],
          region: maps[i]['region'],
          subdivisionGuid: maps[i]['subdivisionGuid']);
    });
  }
}