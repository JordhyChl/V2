// ignore_for_file: no_leading_underscores_for_local_identifiers

class DeviceBusyModel {
  DeviceBusyModel({
    required this.code,
    required this.msg,
    required this.data,
  });
  late final int code;
  late final String msg;
  late final DataDeviceBusy data;

  DeviceBusyModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    data = DataDeviceBusy.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['code'] = code;
    _data['msg'] = msg;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataDeviceBusy {
  DataDeviceBusy({
    required this.code,
    required this.imei,
    required this.msg,
    required this.serverFlagId,
  });
  late final String code;
  late final String imei;
  late final String msg;
  late final String serverFlagId;

  DataDeviceBusy.fromJson(Map<String, dynamic> json) {
    code = json['_code'];
    imei = json['_imei'];
    msg = json['_msg'];
    serverFlagId = json['_serverFlagId'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['_code'] = code;
    _data['_imei'] = imei;
    _data['_msg'] = msg;
    _data['_serverFlagId'] = serverFlagId;
    return _data;
  }
}
