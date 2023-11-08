class CheckImeiModel {
  CheckImeiModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final List<DataImei> data;

  CheckImeiModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = List.from(json['data']).map((e) => DataImei.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.map((e) => e.toJson()).toList();
    return _data;
  }
}

class DataImei {
  DataImei({
    required this.imei,
    required this.branchID,
    required this.name,
    required this.isPortable,
    required this.code,
    required this.typeGps,
    required this.lt_warranty,
  });
  late final String imei;
  late final int branchID;
  late final String name;
  late final bool isPortable;
  late final String code;
  late final String typeGps;
  late final int lt_warranty;

  DataImei.fromJson(Map<String, dynamic> json) {
    imei = json['imei'];
    branchID = json['branch_id'];
    name = json['name'];
    isPortable = json['is_portable'];
    code = json['code'];
    typeGps = json['type_gps'];
    lt_warranty = json['lt_warranty'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['imei'] = imei;
    _data['branch_id'] = branchID;
    _data['name'] = name;
    _data['is_portable'] = isPortable;
    _data['code'] = code;
    _data['type_gps'] = typeGps;
    _data['lt_warranty'] = lt_warranty;
    return _data;
  }
}
