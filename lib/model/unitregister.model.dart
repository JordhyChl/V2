// ignore_for_file: non_constant_identifier_names

class UnitRegisterModel {
  UnitRegisterModel({
    required this.unit,
  });
  late final List<Unit> unit;

  UnitRegisterModel.fromJson(Map<String, dynamic> json) {
    unit = List.from(json['unit']).map((e) => Unit.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['unit'] = unit.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Unit {
  Unit({
    required this.plat,
    required this.vehName,
    required this.gpsName,
    required this.gsmNo,
    required this.imei,
    required this.vehicleType,
    required this.img,
    required this.icon,
    required this.lt_warranty,
    required this.expired_gsm,
    required this.simcard_id,
  });
  late final String plat;
  late final String vehName;
  late final String gpsName;
  late final String gsmNo;
  late final String imei;
  late final int vehicleType;
  late final Img img;
  late final int icon;
  late final int lt_warranty;
  late final String expired_gsm;
  late final String simcard_id;

  Unit.fromJson(Map<String, dynamic> json) {
    plat = json['plat'];
    vehName = json['vehName'];
    gpsName = json['gpsName'];
    gsmNo = json['gsmNo'];
    imei = json['imei'];
    vehicleType = json['vehicle_type'];
    img = Img.fromJson(json['img']);
    icon = json['icon'];
    lt_warranty = json['lt_warranty'];
    expired_gsm = json['expired_gsm'];
    simcard_id = json['simcard_id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['plat'] = plat;
    _data['vehName'] = vehName;
    _data['gpsName'] = gpsName;
    _data['gsmNo'] = gsmNo;
    _data['imei'] = imei;
    _data['vehicle_type'] = vehicleType;
    _data['img'] = img.toJson();
    _data['icon'] = icon;
    _data['lt_warranty'] = lt_warranty;
    _data['expired_gsm'] = expired_gsm;
    _data['simcard_id'] = simcard_id;
    return _data;
  }
}

class Img {
  Img({
    required this.accOn,
    required this.park,
    required this.alarm,
    required this.lost,
  });
  late final String accOn;
  late final String park;
  late final String alarm;
  late final String lost;

  Img.fromJson(Map<String, dynamic> json) {
    accOn = json['accOn'];
    park = json['park'];
    alarm = json['alarm'];
    lost = json['lost'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['accOn'] = accOn;
    _data['park'] = park;
    _data['alarm'] = alarm;
    _data['lost'] = lost;
    return _data;
  }
}
