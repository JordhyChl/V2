// ignore_for_file: no_leading_underscores_for_local_identifiers

class StopReportListModel {
  StopReportListModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataStopReport data;

  StopReportListModel.fromJson(Map<String, dynamic> json) {
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
    required this.totalStopTime,
    required this.result,
  });
  late final int totalAllData;
  // late final int currentPage;
  // late final int perPage;
  // late final int totalPage;
  late final int totalStopTime;
  late final List<ResultStopModel> result;

  DataStopReport.fromJson(Map<String, dynamic> json) {
    totalAllData = json['TotalAllData'];
    // currentPage = json['CurrentPage'];
    // perPage = json['PerPage'];
    // totalPage = json['TotalPage'];
    totalStopTime = json['TotalStopTime'];
    result = List.from(json['result'])
        .map((e) => ResultStopModel.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['TotalAllData'] = totalAllData;
    // _data['CurrentPage'] = currentPage;
    // _data['PerPage'] = perPage;
    // _data['TotalPage'] = totalPage;
    _data['TotalStopTime'] = totalStopTime;
    _data['result'] = result.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ResultStopModel {
  ResultStopModel({
    required this.imei,
    required this.plate,
    required this.gsmNo,
    required this.lon,
    required this.lat,
    required this.start,
    required this.end,
    required this.duration,
    required this.address,
  });
  late final String imei;
  late final String plate;
  late final String gsmNo;
  late final double lon;
  late final double lat;
  late final String start;
  late final String end;
  late final int duration;
  late String address;

  ResultStopModel.fromJson(Map<String, dynamic> json) {
    imei = json['Imei'];
    plate = json['Plate'];
    gsmNo = json['Gsm_no'];
    lon = json['Lon'];
    lat = json['Lat'];
    start = json['Start'];
    end = json['End'];
    duration = json['Duration'];
    address = json['Address'] ?? 'Show address';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Imei'] = imei;
    _data['Plate'] = plate;
    _data['Gsm_no'] = gsmNo;
    _data['Lon'] = lon;
    _data['Lat'] = lat;
    _data['Start'] = start;
    _data['End'] = end;
    _data['Duration'] = duration;
    _data['Address'] = address;
    return _data;
  }
}
