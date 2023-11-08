// ignore_for_file: no_leading_underscores_for_local_identifiers

class NPWPListModel {
  NPWPListModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final List<Data> data;

  NPWPListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = List.from(json['data'] ?? []).map((e) => Data.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Data {
  Data({
    required this.id,
    required this.npwpNo,
    required this.npwpName,
    required this.npwpAddr,
    required this.npwpWa,
    required this.npwpEmail,
    required this.createdAt,
  });
  late final int id;
  late final String npwpNo;
  late final String npwpName;
  late final String npwpAddr;
  late final String npwpWa;
  late final String npwpEmail;
  late final String createdAt;

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    npwpNo = json['npwp_no'];
    npwpName = json['npwp_name'];
    npwpAddr = json['npwp_addr'];
    npwpWa = json['npwp_wa'];
    npwpEmail = json['npwp_email'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['npwp_no'] = npwpNo;
    _data['npwp_name'] = npwpName;
    _data['npwp_addr'] = npwpAddr;
    _data['npwp_wa'] = npwpWa;
    _data['npwp_email'] = npwpEmail;
    _data['created_at'] = createdAt;
    return _data;
  }
}
