import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

Future<List<Field>> fetchFields(bool reload) async {
  final listSavedFields = await dogs();
  if(listSavedFields.isNotEmpty && !reload){
    return listSavedFields;
  }
  final response = await http.get(
    Uri.parse('https://api.cfg.com.ua/machineDriver/test-base/fields'),
    headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + TOKEN,
    },
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var listData = BaseResponse.fromJson(jsonDecode(response.body)).data;
    await insertDog(listData);
    return listData;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load fields');
  }
}

class BaseResponse {
  final String metadataName;
  final int count;
  final List<Field> data;

  const BaseResponse(
      {required this.metadataName, required this.count, required this.data});

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
        metadataName: json['metadataName'],
        count: json['count'],
        data: List<dynamic>.from(json['data'])
            .map((e) => Field.fromJson(e))
            .toList());
  }
}

class Field {
  final String guid;
  final String name;
  final String region;
  final String subdivisionGuid;

  const Field(
      {required this.guid,
      required this.name,
      required this.region,
      required this.subdivisionGuid});

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
        guid: json['guid'],
        name: json['name'],
        region: json['region'],
        subdivisionGuid: json['subdivisionGuid']);
  }

  Map<String, dynamic> toMap() {
    return {
      'guid': guid,
      'name': name,
      'region': region,
      'subdivisionGuid': subdivisionGuid
    };
  }
}

Future<Database> fetchDatabase() async {
  WidgetsFlutterBinding.ensureInitialized();
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

Future<void> insertDog(List<Field> fields) async {
  // Get a reference to the database.
  final db = await fetchDatabase();

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

Future<List<Field>> dogs() async {
  // Get a reference to the database.
  final db = await fetchDatabase();

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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Field>> items;

  @override
  void initState() {
    super.initState();
    items = fetchFields(false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Fields Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Fields Example'),
        ),
        body: Center(
          child: FutureBuilder<List<Field>>(
            future: items,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  // Let the ListView know how many items it needs to build.
                  itemCount: snapshot.data?.length,
                  // Provide a builder function. This is where the magic happens.
                  // Convert each item into a widget based on the type of item it is.
                  itemBuilder: (context, index) {
                    final item = snapshot.data?[index];

                    return ListTile(
                      title: Text("${item?.name}"),
                      subtitle: Text("${item?.region}"),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

}

const TOKEN =
    "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSJ9.eyJhdWQiOiJjMWM4NjYwNS1hMDY1LTQ0MGUtODQzZi04ZGMxNzJiNTMyMDciLCJpc3MiOiJodHRwczovL2xvZ2luLm1pY3Jvc29mdG9ubGluZS5jb20vZTJmNjNlMjAtYzJjMS00YTE0LWFlNGYtMGU3MTU0ZmIzZjY4L3YyLjAiLCJpYXQiOjE2NjM4NDk3OTYsIm5iZiI6MTY2Mzg0OTc5NiwiZXhwIjoxNjYzODU1MTIxLCJhaW8iOiJBVFFBeS84VEFBQUFOTlU1YldaNlg0d3ZaZzhsMFh3a1habHBJTzZkVll6bXE0LzZoeFJiM2E3RFZud3NBRG13UGk2c2FHZWEwbExGIiwiYXpwIjoiNWRlYTc4NGItYmE2OC00MTBiLWI4NjctYjJiZmJlZjU2ZGY1IiwiYXpwYWNyIjoiMSIsIm5hbWUiOiLQndC-0YHQuNC6INCU0LDQvdC40LvQviDQntC70LXQutGB0LDQvdC00YDQvtCy0LjRhyIsIm9pZCI6IjgzNmI2MGFjLTk2YWMtNGQxMC04MWI2LWFmNWJiY2RhZDU0MCIsInByZWZlcnJlZF91c2VybmFtZSI6ImRub3N5a0BjZmcuY29tLnVhIiwicmgiOiIwLkFRa0FJRDcyNHNIQ0ZFcXVUdzV4VlBzX2FBVm15TUZsb0E1RWhELU53WEsxTWdjSkFQVS4iLCJzY3AiOiJTZWN1cml0eS5BbGwiLCJzdWIiOiJUZ0R2RmdtQzJXZFB4MTh1YnNOdjcwR0VoQnpNYUFLWGtoWXJpSFZtU1Q4IiwidGlkIjoiZTJmNjNlMjAtYzJjMS00YTE0LWFlNGYtMGU3MTU0ZmIzZjY4IiwidXRpIjoiSUkyY09iUjZCazJPOVhFVGZTSmhBQSIsInZlciI6IjIuMCJ9.ZABnylIPrUps5Qzx-jRW0jcB2Cx6aydLnmY-cXI9QfDhssSbrzgwqCz1aElEXVGs5nKi9cpGqCkiEdWa9NVZt-MavWXsqLPfUqfZsTLOwSVMdmbeCNrZPaTpAU_yBFK35JOuWdelx4WKJaB5WiufpmFB53648pull2VPXxr0IZotP5mjvIs1XI92wYD-SlcqOSM3kfxoSqbdgpWSMKMUk4LP-MxiI6q-xhwnVOQUK4B-WCCml13Jd_PjqeqjGcj9PrnnTPWpKdtJHpGte5JH3jXgrvDSiCZJj4E-G38gqvlJAFIfkL91A6wlWbmH25FBPI0hBZXXS-fC7K0tgEw22g";
