// ignore_for_file: no_leading_underscores_for_local_identifiers

class RewardListModel {
  RewardListModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataRewardList data;

  RewardListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataRewardList.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataRewardList {
  DataRewardList({
    required this.totalAllData,
    required this.results,
  });
  late final int totalAllData;
  late final List<ResultRewardList> results;

  DataRewardList.fromJson(Map<String, dynamic> json) {
    totalAllData = json['total_all_data'];
    results = List.from(json['results'])
        .map((e) => ResultRewardList.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['total_all_data'] = totalAllData;
    _data['results'] = results.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ResultRewardList {
  ResultRewardList({
    required this.totalData,
    required this.rewardCategoryName,
    required this.dataVoucher,
  });
  late final int totalData;
  late final String rewardCategoryName;
  late final List<DataVoucher> dataVoucher;

  ResultRewardList.fromJson(Map<String, dynamic> json) {
    totalData = json['total_data'];
    rewardCategoryName = json['reward_category_name'];
    dataVoucher = List.from(json['data_voucher'] ?? [])
        .map((e) => DataVoucher.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['total_data'] = totalData;
    _data['reward_category_name'] = rewardCategoryName;
    _data['data_voucher'] = dataVoucher.map((e) => e.toJson()).toList();
    return _data;
  }
}

class DataVoucher {
  DataVoucher({
    required this.rewardId,
    required this.rewardName,
    required this.rewardDescription,
    required this.rewardImageUrl,
    required this.rewardCategoryName,
    required this.rewardPoint,
    required this.rewardCategoryId,
  });
  late final int rewardId;
  late final String rewardName;
  late final String rewardDescription;
  late final String rewardImageUrl;
  late final String rewardCategoryName;
  late final int rewardPoint;
  late final int rewardCategoryId;

  DataVoucher.fromJson(Map<String, dynamic> json) {
    rewardId = json['reward_id'];
    rewardName = json['reward_name'];
    rewardDescription = json['reward_description'];
    rewardImageUrl = json['reward_image_url'];
    rewardCategoryName = json['reward_category_name'];
    rewardPoint = json['reward_point'];
    rewardCategoryId = json['reward_category_id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['reward_id'] = rewardId;
    _data['reward_name'] = rewardName;
    _data['reward_description'] = rewardDescription;
    _data['reward_image_url'] = rewardImageUrl;
    _data['reward_category_name'] = rewardCategoryName;
    _data['reward_point'] = rewardPoint;
    _data['reward_category_id'] = rewardCategoryId;
    return _data;
  }
}
