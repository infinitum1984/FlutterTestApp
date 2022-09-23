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