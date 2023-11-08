// ignore_for_file: no_leading_underscores_for_local_identifiers

class GetPackageModel {
  GetPackageModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final Data data;

  GetPackageModel.fromJson(Map<String, dynamic> json) {
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
    required this.totalAllData,
    required this.results,
  });
  late final int totalAllData;
  late final List<Results> results;

  Data.fromJson(Map<String, dynamic> json) {
    totalAllData = json['total_all_data'];
    results =
        List.from(json['results']).map((e) => Results.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['total_all_data'] = totalAllData;
    _data['results'] = results.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Results {
  Results({
    required this.id,
    required this.packName,
    required this.price,
    required this.topupDays,
    required this.isDefault,
    required this.isPromo,
  });
  late final int id;
  late final String packName;
  late final String price;
  late final String topupDays;
  late final int isDefault;
  late final int isPromo;

  Results.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    packName = json['pack_name'];
    price = json['price'];
    topupDays = json['topup_days'];
    isDefault = json['is_default'];
    isPromo = json['is_promo'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['pack_name'] = packName;
    _data['price'] = price;
    _data['topup_days'] = topupDays;
    _data['is_default'] = isDefault;
    _data['is_promo'] = isPromo;
    return _data;
  }
}
