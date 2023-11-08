class CheckGSMModel {
  CheckGSMModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final Data data;

  CheckGSMModel.fromJson(Map<String, dynamic> json) {
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
    required this.simcardId,
    required this.simcard,
    required this.expired,
    required this.lifetimeWarranty,
    required this.status,
    required this.message,
  });
  late final String simcardId;
  late final String simcard;
  late final String expired;
  late final int lifetimeWarranty;
  late final bool status;
  late final String message;

  Data.fromJson(Map<String, dynamic> json) {
    simcardId = json['simcard_id'];
    simcard = json['simcard'];
    expired = json['expired'];
    lifetimeWarranty = json['lifetime_warranty'];
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['simcard_id'] = simcardId;
    _data['simcard'] = simcard;
    _data['expired'] = expired;
    _data['lifetime_warranty'] = lifetimeWarranty;
    _data['status'] = status;
    _data['message'] = message;
    return _data;
  }
}
