class ShareLocationResultModel {
  ShareLocationResultModel(
      {required this.name,
      required this.email,
      required this.imei,
      required this.url,
      required this.key,
      required this.expiredDate,
      required this.userId,
      required this.id});
  late final String name;
  late final String email;
  late final String imei;
  late final String url;
  late final String key;
  late final String expiredDate;
  late final int userId;
  late final int id;

  ShareLocationResultModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    imei = json['imei'];
    url = json['url'];
    key = json['key'];
    expiredDate = json['expired_date'];
    userId = json['user_id'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['imei'] = imei;
    data['url'] = url;
    data['key'] = key;
    data['expired_date'] = expiredDate;
    data['user_id'] = userId;
    data['id'] = id;
    return data;
  }
}
