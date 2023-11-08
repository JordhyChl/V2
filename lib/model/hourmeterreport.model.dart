// ignore_for_file: no_leading_underscores_for_local_identifiers

class HourmeterReportModel {
  HourmeterReportModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataHourmeterReport data;

  HourmeterReportModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataHourmeterReport.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataHourmeterReport {
  DataHourmeterReport({
    required this.totalAllData,
    // required this.currentPage,
    // required this.perPage,
    // required this.totalPage,
    required this.totalHourMeter,
    required this.result,
  });
  late final int totalAllData;
  // late final int currentPage;
  // late final int perPage;
  // late final int totalPage;
  late final int totalHourMeter;
  late final List<ResultHourmeterReport> result;

  DataHourmeterReport.fromJson(Map<String, dynamic> json) {
    totalAllData = json['TotalAllData'];
    // currentPage = json['CurrentPage'];
    // perPage = json['PerPage'];
    // totalPage = json['TotalPage'];
    totalHourMeter = json['TotalHourMeter'];
    result = List.from(json['result'])
        .map((e) => ResultHourmeterReport.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['TotalAllData'] = totalAllData;
    // _data['CurrentPage'] = currentPage;
    // _data['PerPage'] = perPage;
    // _data['TotalPage'] = totalPage;
    _data['TotalHourMeter'] = totalHourMeter;
    _data['result'] = result.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ResultHourmeterReport {
  ResultHourmeterReport({
    required this.imei,
    required this.plate,
    required this.gsmNo,
    required this.startLon,
    required this.startLat,
    required this.endLon,
    required this.endLat,
    required this.start,
    required this.end,
    required this.startAddress,
    required this.endAddress,
    required this.duration,
    required this.maxSpeed,
    required this.averageSpeed,
    required this.driveMilage,
  });
  late final String imei;
  late final String plate;
  late final String gsmNo;
  late final double startLon;
  late final double startLat;
  late final double endLon;
  late final double endLat;
  late final String start;
  late final String end;
  late String startAddress;
  late String endAddress;
  late final int duration;
  late final int maxSpeed;
  late final int averageSpeed;
  late final int driveMilage;

  ResultHourmeterReport.fromJson(Map<String, dynamic> json) {
    imei = json['Imei'];
    plate = json['Plate'];
    gsmNo = json['Gsm_no'];
    startLon = json['StartLon'];
    startLat = json['StartLat'];
    endLon = json['EndLon'];
    endLat = json['EndLat'];
    start = json['Start'];
    end = json['End'];
    startAddress = 'Show address';
    endAddress = 'Show address';
    duration = json['Duration'];
    maxSpeed = json['MaxSpeed'];
    averageSpeed = json['AverageSpeed'];
    driveMilage = json['DriveMilage'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Imei'] = imei;
    _data['Plate'] = plate;
    _data['Gsm_no'] = gsmNo;
    _data['StartLon'] = startLon;
    _data['StartLat'] = startLat;
    _data['EndLon'] = endLon;
    _data['EndLat'] = endLat;
    _data['Start'] = start;
    _data['End'] = end;
    _data['StartAddress'] = startAddress;
    _data['EndAddress'] = endAddress;
    _data['Duration'] = duration;
    _data['MaxSpeed'] = maxSpeed;
    _data['AverageSpeed'] = averageSpeed;
    _data['DriveMilage'] = driveMilage;
    return _data;
  }
}
