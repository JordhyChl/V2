class ShareLocationPostModel {
  ShareLocationPostModel(
      {required this.name,
      required this.email,
      required this.expiration,
      required this.imei});
  late final String name;
  late final String email;
  late final String expiration;
  late final String imei;

  ShareLocationPostModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    expiration = json['expiration'];
    imei = json['imei'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['expiration'] = expiration;
    data['imei'] = imei;
    return data;
  }
}
