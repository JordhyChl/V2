// ignore_for_file: no_leading_underscores_for_local_identifiers

class AlarmReportModel {
  AlarmReportModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataStopReport data;

  AlarmReportModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataStopReport.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataStopReport {
  DataStopReport({
    required this.totalAllData,
    // required this.currentPage,
    // required this.perPage,
    // required this.totalPage,
    required this.result,
  });
  late final int totalAllData;
  // late final int currentPage;
  // late final int perPage;
  // late final int totalPage;
  late final List<ResultAlarmReport> result;

  DataStopReport.fromJson(Map<String, dynamic> json) {
    totalAllData = json['TotalAllData'];
    // currentPage = json['CurrentPage'];
    // perPage = json['PerPage'];
    // totalPage = json['TotalPage'];
    result = List.from(json['result'])
        .map((e) => ResultAlarmReport.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['TotalAllData'] = totalAllData;
    // _data['CurrentPage'] = currentPage;
    // _data['PerPage'] = perPage;
    // _data['TotalPage'] = totalPage;
    _data['result'] = result.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ResultAlarmReport {
  ResultAlarmReport({
    required this.iD,
    required this.imei,
    required this.lon,
    required this.lat,
    required this.speed,
    required this.address,
    required this.time,
    required this.alert,
    required this.remarkNotif,
    required this.remarkEmail,
    required this.alertText,
  });
  late final int iD;
  late final String imei;
  late final double lon;
  late final double lat;
  late final int speed;
  late String address;
  late final String time;
  late final int alert;
  late final int remarkNotif;
  late final int remarkEmail;
  late final String alertText;

  ResultAlarmReport.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    imei = json['Imei'];
    lon = json['Lon'];
    lat = json['Lat'];
    speed = json['Speed'];
    address = 'Show address';
    time = json['Time'];
    alert = json['Alert'];
    remarkNotif = json['Remark_notif'];
    remarkEmail = json['Remark_email'];
    alertText = json['Alert_text'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['ID'] = iD;
    _data['Imei'] = imei;
    _data['Lon'] = lon;
    _data['Lat'] = lat;
    _data['Speed'] = speed;
    _data['Address'] = address;
    _data['Time'] = time;
    _data['Alert'] = alert;
    _data['Remark_notif'] = remarkNotif;
    _data['Remark_email'] = remarkEmail;
    _data['Alert_text'] = alertText;
    return _data;
  }
}
