import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../model/Field.dart';

class NetworkDatasource{
  Future<List<Field>> fetchFields() async {
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

      return listData;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load fields');
    }
  }
}

const TOKEN =
"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSJ9.eyJhdWQiOiJjMWM4NjYwNS1hMDY1LTQ0MGUtODQzZi04ZGMxNzJiNTMyMDciLCJpc3MiOiJodHRwczovL2xvZ2luLm1pY3Jvc29mdG9ubGluZS5jb20vZTJmNjNlMjAtYzJjMS00YTE0LWFlNGYtMGU3MTU0ZmIzZjY4L3YyLjAiLCJpYXQiOjE2NjM5NDEzMjMsIm5iZiI6MTY2Mzk0MTMyMywiZXhwIjoxNjYzOTQ2NTI4LCJhaW8iOiJBVFFBeS84VEFBQUFWRnBsUzVFa1pIQStML0pxdnJoZ1BremtLR0EycFpubUt1NHZQY1Z5WDdwU0hNMWdCNGc5TU9OeUVuYldoMnlxIiwiYXpwIjoiNWRlYTc4NGItYmE2OC00MTBiLWI4NjctYjJiZmJlZjU2ZGY1IiwiYXpwYWNyIjoiMSIsIm5hbWUiOiLQndC-0YHQuNC6INCU0LDQvdC40LvQviDQntC70LXQutGB0LDQvdC00YDQvtCy0LjRhyIsIm9pZCI6IjgzNmI2MGFjLTk2YWMtNGQxMC04MWI2LWFmNWJiY2RhZDU0MCIsInByZWZlcnJlZF91c2VybmFtZSI6ImRub3N5a0BjZmcuY29tLnVhIiwicmgiOiIwLkFRa0FJRDcyNHNIQ0ZFcXVUdzV4VlBzX2FBVm15TUZsb0E1RWhELU53WEsxTWdjSkFQVS4iLCJzY3AiOiJTZWN1cml0eS5BbGwiLCJzdWIiOiJUZ0R2RmdtQzJXZFB4MTh1YnNOdjcwR0VoQnpNYUFLWGtoWXJpSFZtU1Q4IiwidGlkIjoiZTJmNjNlMjAtYzJjMS00YTE0LWFlNGYtMGU3MTU0ZmIzZjY4IiwidXRpIjoiNVEtaW84M2VLRUtsLUVUMGNUOS1BQSIsInZlciI6IjIuMCJ9.PjSjdSq0BbMV58DCPl0ryPQYNrbvqqcUHjRU-1qZF-JIGFAwLsOLNIRYRi09_BQp6-HL6p2Z6f7xBdd-NPd2qjXjc4S77EmFuVZevfW88PODBdys9CJgx_xdcJIbb2hsoi9CHiF5BsjGaoNUwEwVWCLgATr5inqtXL46ll4oZZBdbZkDjMTiJhDUZokaJH_y3YyoLHY7hKn7dLNHqZrIVzCNc_7FHnRxsk9QJJzxiQFhd8-t_vMDSqMxC2mNN2rp-Qyk45tb7VpEEc9r9s5dG3QIHdvjC2F5ICyljlUVq7lslE24CkpH0DFyux9O4_A39LYD0CtfwNsBiusCBQIHBQ";