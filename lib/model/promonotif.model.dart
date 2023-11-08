// ignore_for_file: no_leading_underscores_for_local_identifiers

class PromoNotifModel {
  PromoNotifModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final List<DataPromoNotif> data;

  PromoNotifModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = List.from(json['data'] ?? [])
        .map((e) => DataPromoNotif.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.map((e) => e.toJson()).toList();
    return _data;
  }
}

class DataPromoNotif {
  DataPromoNotif({
    required this.id,
    required this.title,
    required this.description,
    required this.picture,
    required this.startPublish,
    required this.endPublish,
    required this.subTitle,
    required this.syaratKetentuan,
    required this.type,
  });
  late final int id;
  late final String title;
  late final String description;
  late final String picture;
  late final String startPublish;
  late final String endPublish;
  late final String subTitle;
  late final List<String> syaratKetentuan;
  late final int type;

  DataPromoNotif.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    title = json['Title'];
    description = json['Description'];
    picture = json['Picture'];
    startPublish = json['Start_publish'];
    endPublish = json['End_publish'];
    subTitle = json['Sub_title'];
    syaratKetentuan = List.castFrom<dynamic, String>(json['Syarat_ketentuan']);
    type = json['Type'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Id'] = id;
    _data['Title'] = title;
    _data['Description'] = description;
    _data['Picture'] = picture;
    _data['Start_publish'] = startPublish;
    _data['End_publish'] = endPublish;
    _data['Sub_title'] = subTitle;
    _data['Syarat_ketentuan'] = syaratKetentuan;
    _data['Type'] = type;
    return _data;
  }
}
