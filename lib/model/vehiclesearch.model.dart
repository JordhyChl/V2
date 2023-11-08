// ignore_for_file: no_leading_underscores_for_local_identifiers

class VehicleSearchModel {
  VehicleSearchModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataVehicleSearch data;

  VehicleSearchModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataVehicleSearch.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataVehicleSearch {
  DataVehicleSearch({
    required this.result,
  });
  late final List<ResultVehicleSearch> result;

  DataVehicleSearch.fromJson(Map<String, dynamic> json) {
    result = List.from(json['result'])
        .map((e) => ResultVehicleSearch.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['result'] = result.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ResultVehicleSearch {
  ResultVehicleSearch({
    required this.imei,
    required this.deviceName,
    required this.plate,
    required this.gpsName,
    required this.icon,
    required this.speed,
    required this.lastUpdate,
    required this.lastData,
    required this.status,
    required this.expiredDate,
    required this.lon,
    required this.lat,
    required this.angle,
    required this.battery,
    required this.temperature,
    required this.miliege,
    required this.gsmNo,
    required this.vehType,
    required this.vehBrand,
    required this.isExpired,
    required this.isAccOn,
    required this.alert,
    required this.sevenDays,
  });
  late final String imei;
  late final String deviceName;
  late final String plate;
  late final String gpsName;
  late final int icon;
  late final int speed;
  late final String lastUpdate;
  late final String lastData;
  late final String status;
  late final String expiredDate;
  late final String lon;
  late final String lat;
  late final int angle;
  late final String battery;
  late final String temperature;
  late final int miliege;
  late final String gsmNo;
  late final String vehType;
  late final String vehBrand;
  late final bool isExpired;
  late final bool isAccOn;
  late final String alert;
  late final bool sevenDays;

  ResultVehicleSearch.fromJson(Map<String, dynamic> json) {
    imei = json['Imei'];
    deviceName = json['DeviceName'];
    plate = json['Plate'];
    gpsName = json['GpsName'];
    icon = json['Icon'];
    speed = json['Speed'];
    lastUpdate = json['LastUpdate'];
    lastData = json['LastData'];
    status = json['Status'];
    expiredDate = json['ExpiredDate'];
    lon = json['Lon'] == '0' || json['Lon'] == '' ? '0.0' : json['Lon'];
    lat = json['Lat'] == '0' || json['Lat'] == '' ? '0.0' : json['Lat'];
    angle = json['Angle'];
    battery = json['Battery'];
    temperature = json['Temperature'];
    miliege = json['Miliege'];
    gsmNo = json['Gsm_no'];
    vehType = json['Veh_type'] == ''
        ? 'car'
        : json['Veh_type'] == 'Other'
            ? 'car'
            : json['Veh_type'];
    vehBrand = json['Veh_brand'];
    isExpired = json['Is_Expired'];
    isAccOn = json['Is_Acc_On'];
    alert = json['Alert'];
    sevenDays = json['SevenDaysExp'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Imei'] = imei;
    _data['DeviceName'] = deviceName;
    _data['Plate'] = plate;
    _data['GpsName'] = gpsName;
    _data['Icon'] = icon;
    _data['Speed'] = speed;
    _data['LastUpdate'] = lastUpdate;
    _data['LastData'] = lastData;
    _data['Status'] = status;
    _data['ExpiredDate'] = expiredDate;
    _data['Lon'] = lon;
    _data['Lat'] = lat;
    _data['Angle'] = angle;
    _data['Battery'] = battery;
    _data['Temperature'] = temperature;
    _data['Miliege'] = miliege;
    _data['Gsm_no'] = gsmNo;
    _data['Veh_type'] = vehType;
    _data['Veh_brand'] = vehBrand;
    _data['Is_Expired'] = isExpired;
    _data['Is_Acc_On'] = isAccOn;
    _data['Alert'] = alert;
    _data['SevenDaysExp'] = sevenDays;
    return _data;
  }
}
