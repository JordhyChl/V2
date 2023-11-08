class VehicleDetailModel {
  VehicleDetailModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataVehicleDetail data;

  VehicleDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataVehicleDetail.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataVehicleDetail {
  DataVehicleDetail({
    required this.result,
  });
  late final ResultVehicleDetail result;

  DataVehicleDetail.fromJson(Map<String, dynamic> json) {
    result = ResultVehicleDetail.fromJson(json['result']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['result'] = result.toJson();
    return _data;
  }
}

class ResultVehicleDetail {
  ResultVehicleDetail({
    required this.imei,
    required this.plate,
    required this.gsmNo,
    required this.vehicleStatus,
    required this.lon,
    required this.lat,
    required this.speed,
    required this.battery,
    required this.temperature,
    required this.icon,
    required this.lastUpdate,
    required this.odoMeter,
    required this.door,
    required this.features,
    required this.isAccOn,
    required this.description,
    required this.lastData,
    required this.lifetimeWarranty,
    required this.registerDate,
    required this.angle,
    required this.totalCamera,
    required this.statusEngine,
    required this.timeEngine,
    required this.engine,
  });
  late final String imei;
  late final String plate;
  late final String gsmNo;
  late final String vehicleStatus;
  late final String lon;
  late final String lat;
  late final int speed;
  late final String battery;
  late final String temperature;
  late final int icon;
  late final String lastUpdate;
  late final int odoMeter;
  late final String door;
  late final List<FeaturesVehicleDetail> features;
  late final bool isAccOn;
  late final String description;
  late final String lastData;
  late final String lifetimeWarranty;
  late final String registerDate;
  late final int angle;
  late final int totalCamera;
  late final String statusEngine;
  late final String timeEngine;
  late final EngineTime engine;

  ResultVehicleDetail.fromJson(Map<String, dynamic> json) {
    imei = json['Imei'];
    plate = json['Plate'];
    gsmNo = json['Gsm_no'];
    vehicleStatus = json['VehicleStatus'];
    lon = json['Lon'];
    lat = json['Lat'];
    speed = json['Speed'];
    battery = json['Battery'];
    temperature = json['Temperature'];
    icon = json['Icon'];
    lastUpdate = json['LastUpdate'];
    odoMeter = json['OdoMeter'];
    door = json['Door'];
    features = List.from(json['Features'] ?? {})
        .map((e) => FeaturesVehicleDetail.fromJson(e))
        .toList();
    isAccOn = json['Is_Acc_On'];
    description = json['Description'];
    lastData = json['LastData'];
    lifetimeWarranty = json['LifetimeWarranty'];
    registerDate = json['RegisterDate'];
    angle = json['Angle'];
    totalCamera = json['TotalCamera'];
    statusEngine = json['StatusEngine'];
    timeEngine = json['TimeEngine'];
    engine = EngineTime.fromJson(json['Engine']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Imei'] = imei;
    _data['Plate'] = plate;
    _data['Gsm_no'] = gsmNo;
    _data['VehicleStatus'] = vehicleStatus;
    _data['Lon'] = lon;
    _data['Lat'] = lat;
    _data['Speed'] = speed;
    _data['Battery'] = battery;
    _data['Temperature'] = temperature;
    _data['Icon'] = icon;
    _data['LastUpdate'] = lastUpdate;
    _data['OdoMeter'] = odoMeter;
    _data['Door'] = door;
    _data['Features'] = features.map((e) => e.toJson()).toList();
    _data['Is_Acc_On'] = isAccOn;
    _data['Description'] = description;
    _data['LastData'] = lastData;
    _data['LifetimeWarranty'] = lifetimeWarranty;
    _data['RegisterDate'] = registerDate;
    _data['Angle'] = angle;
    _data['TotalCamera'] = totalCamera;
    _data['StatusEngine'] = statusEngine;
    _data['TimeEngine'] = timeEngine;
    _data['Engine'] = engine.toJson();
    return _data;
  }
}

class FeaturesVehicleDetail {
  FeaturesVehicleDetail({
    required this.gpsType,
    required this.isAcc,
    required this.isCall,
    required this.isDashcam,
    required this.isDoor,
    required this.isEngineOff,
    required this.isEngineOn,
    required this.isTemp,
    required this.smsOff,
    required this.smsOn,
  });
  late final String gpsType;
  late final bool isAcc;
  late final bool isCall;
  late final bool isDashcam;
  late final bool isDoor;
  late final bool isEngineOff;
  late final bool isEngineOn;
  late final bool isTemp;
  late final String smsOff;
  late final String smsOn;

  FeaturesVehicleDetail.fromJson(Map<String, dynamic> json) {
    gpsType = json['gpsType'];
    isAcc = json['isAcc'];
    isCall = json['isCall'];
    isDashcam = json['isDashcam'];
    isDoor = json['isDoor'];
    isEngineOff = json['isEngineOff'];
    isEngineOn = json['isEngineOn'];
    isTemp = json['isTemp'];
    smsOff = json['smsOff'];
    smsOn = json['smsOn'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['gpsType'] = gpsType;
    _data['isAcc'] = isAcc;
    _data['isCall'] = isCall;
    _data['isDashcam'] = isDashcam;
    _data['isDoor'] = isDoor;
    _data['isEngineOff'] = isEngineOff;
    _data['isEngineOn'] = isEngineOn;
    _data['isTemp'] = isTemp;
    _data['smsOff'] = smsOff;
    _data['smsOn'] = smsOn;
    return _data;
  }
}

class EngineTime {
  EngineTime({
    required this.day,
    required this.hour,
    required this.minute,
    required this.second,
  });
  late final int day;
  late final int hour;
  late final int minute;
  late final int second;

  EngineTime.fromJson(Map<String, dynamic> json) {
    day = json['Day'];
    hour = json['Hour'];
    minute = json['Minute'];
    second = json['Second'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Day'] = day;
    _data['Hour'] = hour;
    _data['Minute'] = minute;
    _data['Second'] = second;
    return _data;
  }
}
