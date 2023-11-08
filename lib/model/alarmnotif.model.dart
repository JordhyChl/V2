// ignore_for_file: no_leading_underscores_for_local_identifiers

class AlarmNotif {
  AlarmNotif({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataAlarmNotif data;

  AlarmNotif.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataAlarmNotif.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataAlarmNotif {
  DataAlarmNotif({
    required this.totalAllData,
    required this.result,
  });
  late final int totalAllData;
  late final List<ResultAlarmNotif> result;

  DataAlarmNotif.fromJson(Map<String, dynamic> json) {
    totalAllData = json['TotalAllData'];
    result = List.from(json['result'] ?? {})
        .map((e) => ResultAlarmNotif.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['TotalAllData'] = totalAllData;
    _data['result'] = result.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ResultAlarmNotif {
  ResultAlarmNotif({
    required this.userId,
    required this.type,
    required this.imei,
    required this.username,
    required this.plat,
    required this.code,
    required this.alertCode,
    required this.bodyId,
    required this.bodyEn,
    required this.time,
    required this.lon,
    required this.lat,
  });
  late final int userId;
  late final String type;
  late final String imei;
  late final String username;
  late final String plat;
  late final String code;
  late final String alertCode;
  late final String bodyId;
  late final String bodyEn;
  late final String time;
  late final String lon;
  late final String lat;

  ResultAlarmNotif.fromJson(Map<String, dynamic> json) {
    userId = json['User_id'];
    type = json['Type'];
    imei = json['Imei'];
    username = json['Username'];
    plat = json['Plat'];
    code = json['Code'];
    alertCode = json['Alert_code'];
    bodyId = json['Body_id'];
    bodyEn = json['Body_en'];
    time = json['Time'];
    lon = json['Lon'];
    lat = json['Lat'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['User_id'] = userId;
    _data['Type'] = type;
    _data['Imei'] = imei;
    _data['Username'] = username;
    _data['Plat'] = plat;
    _data['Code'] = code;
    _data['Alert_code'] = alertCode;
    _data['Body_id'] = bodyId;
    _data['Body_en'] = bodyEn;
    _data['Time'] = time;
    _data['Lon'] = lon;
    _data['Lat'] = lat;
    return _data;
  }
}
