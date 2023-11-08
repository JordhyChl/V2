// ignore_for_file: no_leading_underscores_for_local_identifiers

class GetCartModel {
  GetCartModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final Data data;

  GetCartModel.fromJson(Map<String, dynamic> json) {
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
    required this.sim,
    required this.expired,
    required this.bulanExpired,
    required this.nextExpired,
    required this.username,
    required this.information,
    required this.dateInserted,
    required this.harga,
    required this.status,
    required this.orderId,
    required this.domain,
    required this.via,
    required this.userInserted,
    required this.simStatus,
    required this.npwpId,
    required this.topUpPackId,
    required this.packName,
    required this.isSelected,
  });
  late final int id;
  late final String sim;
  late final String expired;
  late final int bulanExpired;
  late final String nextExpired;
  late final String username;
  late final List<String> information;
  late final String dateInserted;
  late final int harga;
  late final int status;
  late final String orderId;
  late final String domain;
  late final String via;
  late final String userInserted;
  late final int simStatus;
  late final int npwpId;
  late final int topUpPackId;
  late final String packName;
  bool isSelected = false;
  late final bool isAvailable;
  late final String vehicleType;
  late final String vehicleStatus;

  Results.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sim = json['sim'];
    expired = json['expired'];
    bulanExpired = json['bulan_expired'];
    nextExpired = json['next_expired'];
    username = json['username'];
    information = List.castFrom<dynamic, String>(json['information']);
    dateInserted = json['date_inserted'];
    harga = json['harga'];
    status = json['status'];
    orderId = json['order_id'];
    domain = json['domain'];
    via = json['via'];
    userInserted = json['user_inserted'];
    simStatus = json['sim_status'];
    npwpId = json['npwp_id'];
    topUpPackId = json['top_up_pack_id'];
    packName = json['package_name'];
    isSelected = json['IsSelected'] = false;
    isAvailable = json['is_available'];
    vehicleType = json['vehicle_type'];
    vehicleStatus = json['vehicle_status'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['sim'] = sim;
    _data['expired'] = expired;
    _data['bulan_expired'] = bulanExpired;
    _data['next_expired'] = nextExpired;
    _data['username'] = username;
    _data['information'] = information;
    _data['date_inserted'] = dateInserted;
    _data['harga'] = harga;
    _data['status'] = status;
    _data['order_id'] = orderId;
    _data['domain'] = domain;
    _data['via'] = via;
    _data['user_inserted'] = userInserted;
    _data['sim_status'] = simStatus;
    _data['npwp_id'] = npwpId;
    _data['top_up_pack_id'] = topUpPackId;
    _data['package_name'] = packName;
    _data['IsSelected'] = isSelected;
    _data['is_available'] = isAvailable;
    _data['vehicle_type'] = vehicleType;
    _data['vehicle_status'] = vehicleStatus;
    return _data;
  }
}
