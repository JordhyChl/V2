// ignore_for_file: no_leading_underscores_for_local_identifiers

class InfoNotifModel {
  InfoNotifModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final List<DataInfoNotif> data;

  InfoNotifModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = List.from(json['data'] ?? [])
        .map((e) => DataInfoNotif.fromJson(e))
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

class DataInfoNotif {
  DataInfoNotif({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.description,
    required this.descriptionEn,
    required this.picture,
    required this.startPublish,
    required this.endPublish,
    required this.subTitle,
    required this.type,
    required this.syaratKetentuan,
  });
  late final int id;
  late final String title;
  late final String titleEn;
  late final String description;
  late final String descriptionEn;
  late final String picture;
  late final String startPublish;
  late final String endPublish;
  late final String subTitle;
  late final int type;
  late final List<String> syaratKetentuan;

  DataInfoNotif.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    title = json['Title'];
    titleEn = json['Title_en'];
    description = json['Description'];
    descriptionEn = json['Description_en'];
    picture = json['Picture'];
    startPublish = json['Start_publish'];
    endPublish = json['End_publish'];
    subTitle = json['Sub_title'];
    type = json['Type'];
    syaratKetentuan = List.castFrom<dynamic, String>(json['Syarat_ketentuan']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Id'] = id;
    _data['Title'] = title;
    _data['Title_en'] = titleEn;
    _data['Description'] = description;
    _data['Description_en'] = descriptionEn;
    _data['Picture'] = picture;
    _data['Start_publish'] = startPublish;
    _data['End_publish'] = endPublish;
    _data['Sub_title'] = subTitle;
    _data['Type'] = type;
    _data['Syarat_ketentuan'] = syaratKetentuan;
    return _data;
  }
}
