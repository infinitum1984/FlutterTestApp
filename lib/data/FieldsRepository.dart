import 'dart:io';

import 'package:test_app_flutter/data/cache/CacheDatasource.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'model/Field.dart';
import 'net/NetworkDatasource.dart';

class FieldsRepository {
  final _networkDataSource = NetworkDatasource();
  final _cacheDataSource = CacheDatasource();

  Future<List<Field>> fetchFields(bool reload) async {
    if (!kIsWeb) {
      final savedFields = await _cacheDataSource.getSavedFields();
      if (savedFields.isNotEmpty && !reload) return savedFields;
    }

    final networkFields = await _networkDataSource.fetchFields();
    if (!kIsWeb) {
      await _cacheDataSource.insertFields(networkFields);
    }
    return networkFields;
  }
}
