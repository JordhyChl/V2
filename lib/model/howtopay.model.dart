class HowToPayModel {
  HowToPayModel({
    required this.code,
    required this.status,
    required this.data,
  });
  late final int code;
  late final String status;
  late final List<Data> data;

  HowToPayModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    status = json['status'];
    data = List.from(json['data']).map((e) => Data.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['code'] = code;
    _data['status'] = status;
    _data['data'] = data.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Data {
  Data({
    required this.title,
    required this.detailsId,
    required this.detailsEn,
  });
  late final String title;
  late final List<String> detailsId;
  late final List<String> detailsEn;

  Data.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    detailsId = List.castFrom<dynamic, String>(json['details_id']);
    detailsEn = List.castFrom<dynamic, String>(json['details_en']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['title'] = title;
    _data['details_id'] = detailsId;
    _data['details_en'] = detailsEn;
    return _data;
  }
}
