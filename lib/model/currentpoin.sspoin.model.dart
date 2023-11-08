// ignore_for_file: no_leading_underscores_for_local_identifiers

class SSPOINCurrentPoinModel {
  SSPOINCurrentPoinModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataSSPoin data;

  SSPOINCurrentPoinModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataSSPoin.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataSSPoin {
  DataSSPoin({
    required this.id,
    required this.currentPoint,
    required this.isBlock,
  });
  late final int id;
  late final int currentPoint;
  late final bool isBlock;

  DataSSPoin.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currentPoint = json['current_point'];
    isBlock = json['is_block'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['current_point'] = currentPoint;
    _data['is_block'] = isBlock;
    return _data;
  }
}
