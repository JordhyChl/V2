class DetailAddCart {
  DetailAddCart({
    required this.details,
  });
  late final List<DetailsCart> details;

  DetailAddCart.fromJson(Map<String, dynamic> json) {
    details =
        List.from(json['details']).map((e) => DetailsCart.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['details'] = details.map((e) => e.toJson()).toList();
    return data;
  }
}

class DetailsCart {
  DetailsCart({
    required this.vehicle,
    required this.topupPack,
  });
  late final VehicleAddToCart vehicle;
  late final int topupPack;

  DetailsCart.fromJson(Map<String, dynamic> json) {
    vehicle = VehicleAddToCart.fromJson(json['vehicle']);
    topupPack = json['top_up_pack_id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['vehicle'] = vehicle.toJson();
    data['top_up_pack_id'] = topupPack;
    return data;
  }
}

class VehicleAddToCart {
  VehicleAddToCart({
    required this.plate,
    required this.sim,
  });
  late final String plate;
  late final String sim;

  VehicleAddToCart.fromJson(Map<String, dynamic> json) {
    plate = json['plate'];
    sim = json['sim'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['plate'] = plate;
    data['sim'] = sim;
    return data;
  }
}
