// ignore_for_file: no_leading_underscores_for_local_identifiers

class RedeemPulsaGetGSMModel {
  RedeemPulsaGetGSMModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final List<DataGSM> data;

  RedeemPulsaGetGSMModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = List.from(json['data']).map((e) => DataGSM.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.map((e) => e.toJson()).toList();
    return _data;
  }
}

class DataGSM {
  DataGSM({
    required this.gsmNo,
    required this.imei,
    required this.owner,
    required this.plate,
    required this.status,
  });
  late final String gsmNo;
  late final String imei;
  late final String owner;
  late final String plate;
  late final int status;

  DataGSM.fromJson(Map<String, dynamic> json) {
    gsmNo = json['gsm_no'];
    imei = json['imei'];
    owner = json['owner'];
    plate = json['plate'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['gsm_no'] = gsmNo;
    _data['imei'] = imei;
    _data['owner'] = owner;
    _data['plate'] = plate;
    _data['status'] = status;
    return _data;
  }
}
