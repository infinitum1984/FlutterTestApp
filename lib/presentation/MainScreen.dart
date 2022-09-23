import 'package:flutter/material.dart';
import 'package:test_app_flutter/data/FieldsRepository.dart';

import '../data/model/Field.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<Field>> items = Future(() => List.empty());
  final fieldsRepo = FieldsRepository();

  @override
  void initState() {
    super.initState();
    //items = fieldsRepo.fetchFields(false);
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

            child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Field>>(
                future: items,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data?.length,
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
                  return const CircularProgressIndicator(

                  );
                },
              ),
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.all(8),
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          items = fieldsRepo.fetchFields(false);
                        });
                      },
                      child: Text("Load list"),
                  ),
                ),

                Container(
                  margin: EdgeInsets.all(8),
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          items = fieldsRepo.fetchFields(true);
                        });
                      },
                      child: Text("Update list")),
                )
              ],
            )
          ],
        )),
      ),
    );
  }
}
