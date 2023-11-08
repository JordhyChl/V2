// ignore_for_file: no_leading_underscores_for_local_identifiers

class CheckLimitModel {
  CheckLimitModel({
    required this.status,
    required this.data,
    required this.message,
  });
  late final bool status;
  late final Data data;
  late final String message;

  CheckLimitModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = Data.fromJson(json['data']);
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['data'] = data.toJson();
    _data['message'] = message;
    return _data;
  }
}

class Data {
  Data({
    required this.imei,
    required this.limitLive,
  });
  late final String imei;
  late final int limitLive;

  Data.fromJson(Map<String, dynamic> json) {
    imei = json['imei'];
    limitLive = json['limit_live'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['imei'] = imei;
    _data['limit_live'] = limitLive;
    return _data;
  }
}
