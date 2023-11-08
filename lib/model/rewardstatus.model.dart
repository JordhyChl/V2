// ignore_for_file: no_leading_underscores_for_local_identifiers

class RedeemStatusModel {
  RedeemStatusModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final RedeemStatusData data;

  RedeemStatusModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = RedeemStatusData.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class RedeemStatusData {
  RedeemStatusData({
    required this.totalAllData,
    required this.result,
  });
  late final int totalAllData;
  late final List<RedeemStatusResult> result;

  RedeemStatusData.fromJson(Map<String, dynamic> json) {
    totalAllData = json['TotalAllData'];
    result = List.from(json['Result'])
        .map((e) => RedeemStatusResult.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['TotalAllData'] = totalAllData;
    _data['Result'] = result.map((e) => e.toJson()).toList();
    return _data;
  }
}

class RedeemStatusResult {
  RedeemStatusResult({
    required this.id,
    required this.userId,
    required this.rewardName,
    required this.description,
    required this.image,
    required this.pointReward,
    required this.requestDate,
    required this.statusValidation,
    required this.redeemNo,
    required this.note,
    required this.statusRedeemIdn,
    required this.statusRedeemEng,
  });
  late final int id;
  late final int userId;
  late final String rewardName;
  late final String description;
  late final String image;
  late final int pointReward;
  late final String requestDate;
  late final int statusValidation;
  late final String redeemNo;
  late final String note;
  late final String statusRedeemIdn;
  late final String statusRedeemEng;

  RedeemStatusResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    rewardName = json['reward_name'];
    description = json['description'];
    image = json['image'];
    pointReward = json['point_reward'];
    requestDate = json['request_date'];
    statusValidation = json['status_validation'];
    redeemNo = json['redeem_no'];
    note = json['note'];
    statusRedeemIdn = json['status_redeem_idn'];
    statusRedeemEng = json['status_redeem_eng'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['user_id'] = userId;
    _data['reward_name'] = rewardName;
    _data['description'] = description;
    _data['image'] = image;
    _data['point_reward'] = pointReward;
    _data['request_date'] = requestDate;
    _data['status_validation'] = statusValidation;
    _data['redeem_no'] = redeemNo;
    _data['note'] = note;
    _data['status_redeem_idn'] = statusRedeemIdn;
    _data['status_redeem_eng'] = statusRedeemEng;
    return _data;
  }
}
