// ignore_for_file: no_leading_underscores_for_local_identifiers

class ProductDetailModel {
  ProductDetailModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataProductDetail data;

  ProductDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataProductDetail.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataProductDetail {
  DataProductDetail({
    required this.iD,
    required this.name,
    required this.description,
    required this.picture,
    required this.features,
    required this.installation,
  });
  late final int iD;
  late final String name;
  late final String description;
  late final String picture;
  late final List<FeaturesProductDetail> features;
  late final String installation;

  DataProductDetail.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    name = json['Name'];
    description = json['Description'];
    picture = json['Picture'];
    features = List.from(json['Features'])
        .map((e) => FeaturesProductDetail.fromJson(e))
        .toList();
    installation = json['Installation'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['ID'] = iD;
    _data['Name'] = name;
    _data['Description'] = description;
    _data['Picture'] = picture;
    _data['Features'] = features.map((e) => e.toJson()).toList();
    _data['Installation'] = installation;
    return _data;
  }
}

class FeaturesProductDetail {
  FeaturesProductDetail({
    required this.iD,
    required this.name,
    required this.description,
    required this.icon,
  });
  late final int iD;
  late final String name;
  late final String description;
  late final String icon;

  FeaturesProductDetail.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    name = json['Name'];
    description = json['Description'];
    icon = json['Icon'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['ID'] = iD;
    _data['Name'] = name;
    _data['Description'] = description;
    _data['Icon'] = icon;
    return _data;
  }
}
