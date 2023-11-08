// ignore_for_file: no_leading_underscores_for_local_identifiers

class DeviceModel {
  DeviceModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final Data data;

  DeviceModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = Data.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class Data {
  Data({
    required this.result,
  });
  late final ResultModel result;

  Data.fromJson(Map<String, dynamic> json) {
    result = ResultModel.fromJson(json['result']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['result'] = result.toJson();
    return _data;
  }
}

class ResultModel {
  ResultModel(
      {required this.imei,
      required this.gpsType,
      required this.deviceName,
      required this.vehicleType,
      required this.palte,
      required this.gsmNumber,
      required this.icon,
      required this.stnk,
      required this.adminBranch,
      required this.ownerName,
      required this.instalationTech,
      required this.year,
      required this.machineNumber,
      required this.chassisNumber,
      required this.speedLimit,
      required this.norangka,
      required this.nomesin,
      required this.limitLive});
  late final String imei;
  late final String gpsType;
  late final String deviceName;
  late final String vehicleType;
  late final String palte;
  late final String gsmNumber;
  late final int icon;
  late final String stnk;
  late final String adminBranch;
  late final String ownerName;
  late final String instalationTech;
  late final int year;
  late final String machineNumber;
  late final String chassisNumber;
  late final int speedLimit;
  late final String norangka;
  late final String nomesin;
  late final int limitLive;

  ResultModel.fromJson(Map<String, dynamic> json) {
    imei = json['Imei'];
    gpsType = json['GpsType'];
    deviceName = json['DeviceName'];
    vehicleType = json['VehicleType'];
    palte = json['Palte'];
    gsmNumber = json['GsmNumber'];
    icon = json['Icon'];
    stnk = json['Stnk'];
    adminBranch = json['AdminBranch'];
    ownerName = json['OwnerName'];
    instalationTech = json['InstalationTech'];
    year = json['Year'];
    machineNumber = json['MachineNumber'];
    chassisNumber = json['ChassisNumber'];
    speedLimit = json['SpeedLimit'];
    norangka = json['Norangka'];
    nomesin = json['Nomesin'];
    limitLive = json['LimitLive'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Imei'] = imei;
    _data['GpsType'] = gpsType;
    _data['DeviceName'] = deviceName;
    _data['VehicleType'] = vehicleType;
    _data['Palte'] = palte;
    _data['GsmNumber'] = gsmNumber;
    _data['Icon'] = icon;
    _data['Stnk'] = stnk;
    _data['AdminBranch'] = adminBranch;
    _data['OwnerName'] = ownerName;
    _data['InstalationTech'] = instalationTech;
    _data['Year'] = year;
    _data['MachineNumber'] = machineNumber;
    _data['ChassisNumber'] = chassisNumber;
    _data['SpeedLimit'] = speedLimit;
    _data['Norangka'] = norangka;
    _data['Nomesin'] = nomesin;
    _data['LimitLive'] = limitLive;
    return _data;
  }
}
