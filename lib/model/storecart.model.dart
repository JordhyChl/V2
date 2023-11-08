// ignore_for_file: no_leading_underscores_for_local_identifiers

class StoreCart {
  StoreCart({
    required this.user,
    required this.vehicle,
    required this.isMobile,
  });
  late final User user;
  late final List<VehicleToCart> vehicle;
  late final int isMobile;

  StoreCart.fromJson(Map<String, dynamic> json) {
    user = User.fromJson(json['user']);
    vehicle = List.from(json['vehicle'])
        .map((e) => VehicleToCart.fromJson(e))
        .toList();
    isMobile = json['is_mobile'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['user'] = user.toJson();
    _data['vehicle'] = vehicle.map((e) => e.toJson()).toList();
    _data['is_mobile'] = isMobile;
    return _data;
  }
}

class User {
  User({
    required this.username,
    required this.domain,
    required this.fullname,
  });
  late final String username;
  late final String domain;
  late final String fullname;

  User.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    domain = json['domain'];
    fullname = json['fullname'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['username'] = username;
    _data['domain'] = domain;
    _data['fullname'] = fullname;
    return _data;
  }
}

class VehicleToCart {
  VehicleToCart({
    required this.plate,
    required this.sim,
    required this.topUpPackId,
  });
  late final String plate;
  late final String sim;
  late final int topUpPackId;

  VehicleToCart.fromJson(Map<String, dynamic> json) {
    plate = json['plate'];
    sim = json['sim'];
    topUpPackId = json['top_up_pack_id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['plate'] = plate;
    _data['sim'] = sim;
    _data['top_up_pack_id'] = topUpPackId;
    return _data;
  }
}
