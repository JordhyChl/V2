// ignore_for_file: no_leading_underscores_for_local_identifiers, non_constant_identifier_names

class POIModel {
  POIModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataPOI data;

  POIModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataPOI.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataPOI {
  DataPOI({
    required this.TotalAllData,
    required this.result,
  });
  late final int TotalAllData;
  late final List<ResultPOI> result;

  DataPOI.fromJson(Map<String, dynamic> json) {
    TotalAllData = json['TotalAllData'];
    result =
        List.from(json['result']).map((e) => ResultPOI.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['TotalAllData'] = TotalAllData;
    _data['result'] = result.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ResultPOI {
  ResultPOI({
    required this.id,
    required this.name,
    required this.lon,
    required this.lat,
    required this.geom,
    required this.type,
    required this.iconId,
    required this.iconName,
  });
  late final int id;
  late final String name;
  late final double lon;
  late final double lat;
  late String geom;
  late final int type;
  late final int iconId;
  late final String iconName;

  ResultPOI.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    lon = json['Lon'];
    lat = json['Lat'];
    geom = json['Geom'];
    type = json['Type'];
    iconId = json['Icon_id'];
    iconName = json['Icon_name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Id'] = id;
    _data['Name'] = name;
    _data['Lon'] = lon;
    _data['Lat'] = lat;
    _data['Geom'] = geom;
    _data['Type'] = type;
    _data['Icon_id'] = iconId;
    _data['Icon_name'] = iconName;
    return _data;
  }
}
