class GetClaraModel {
  GetClaraModel({
    required this.status,
    required this.dataClara,
  });
  late final bool status;
  late final DataClara dataClara;

  GetClaraModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    dataClara = DataClara.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['data'] = dataClara.toJson();
    return data;
  }
}

class DataClara {
  DataClara({
    required this.expired,
    required this.sevenday,
    required this.threeday,
  });
  late final int expired;
  late final int sevenday;
  late final int threeday;

  DataClara.fromJson(Map<String, dynamic> json) {
    expired = json['expired'];
    sevenday = json['sevenday'];
    threeday = json['threeday'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['expired'] = expired;
    data['sevenday'] = sevenday;
    data['threeday'] = threeday;
    return data;
  }
}
