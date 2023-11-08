// ignore_for_file: no_leading_underscores_for_local_identifiers

class TrackReplayModel {
  TrackReplayModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataTrackReplay data;

  TrackReplayModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataTrackReplay.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataTrackReplay {
  DataTrackReplay({
    required this.totalAllData,
    required this.totalDistance,
    required this.result,
  });
  late final int totalAllData;
  late final int totalDistance;
  late final List<ResultTrackReplay> result;

  DataTrackReplay.fromJson(Map<String, dynamic> json) {
    totalAllData = json['TotalAllData'];
    totalDistance = json['TotalDistance'];
    result = List.from(json['result'])
        .map((e) => ResultTrackReplay.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['TotalAllData'] = totalAllData;
    _data['TotalDistance'] = totalDistance;
    _data['result'] = result.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ResultTrackReplay {
  ResultTrackReplay({
    required this.imei,
    required this.plate,
    required this.gsmNo,
    required this.time,
    required this.address,
    required this.lon,
    required this.lat,
    required this.angle,
    required this.acc,
    required this.speed,
    required this.status,
  });
  late final String imei;
  late final String plate;
  late final String gsmNo;
  late final String time;
  late final String address;
  late final double lon;
  late final double lat;
  late final int angle;
  late final int acc;
  late final int speed;
  late final String status;
  late final int milleage;

  ResultTrackReplay.fromJson(Map<String, dynamic> json) {
    imei = json['Imei'];
    plate = json['Plate'];
    gsmNo = json['Gsm_no'];
    time = json['Time'];
    address = json['Address'];
    lon = json['Lon'];
    lat = json['Lat'];
    angle = json['Angle'];
    acc = json['Acc'];
    speed = json['Speed'];
    status = json['Status'];
    milleage = json['Mileage'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Imei'] = imei;
    _data['Plate'] = plate;
    _data['Gsm_no'] = gsmNo;
    _data['Time'] = time;
    _data['Address'] = address;
    _data['Lon'] = lon;
    _data['Lat'] = lat;
    _data['Angle'] = angle;
    _data['Acc'] = acc;
    _data['Speed'] = speed;
    _data['Status'] = status;
    _data['Mileage'] = milleage;
    return _data;
  }
}
