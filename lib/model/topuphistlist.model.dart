// ignore_for_file: no_leading_underscores_for_local_identifiers

class TopupHistModel {
  TopupHistModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataTopupHistoryList data;

  TopupHistModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataTopupHistoryList.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataTopupHistoryList {
  DataTopupHistoryList({
    required this.totalAllData,
    required this.result,
  });
  late final int totalAllData;
  late final List<ResultTopUpHistList> result;

  DataTopupHistoryList.fromJson(Map<String, dynamic> json) {
    totalAllData = json['TotalAllData'];
    result = List.from(json['result'] ?? {})
        .map((e) => ResultTopUpHistList.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['TotalAllData'] = totalAllData;
    _data['result'] = result.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ResultTopUpHistList {
  ResultTopUpHistList({
    required this.orderId,
    required this.paymentType,
    required this.totalPrice,
    required this.trxDate,
    required this.trxTime,
    required this.status,
    required this.totalUnit,
  });
  late final String orderId;
  late final String paymentType;
  late final int totalPrice;
  late final String trxDate;
  late final String trxTime;
  late final String status;
  late final int totalUnit;

  ResultTopUpHistList.fromJson(Map<String, dynamic> json) {
    orderId = json['OrderId'];
    paymentType = json['PaymentType'];
    totalPrice = json['TotalPrice'];
    trxDate = json['TrxDate'];
    trxTime = json['TrxTime'];
    status = json['Status'];
    totalUnit = json['TotalUnit'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['OrderId'] = orderId;
    _data['PaymentType'] = paymentType;
    _data['TotalPrice'] = totalPrice;
    _data['TrxDate'] = trxDate;
    _data['TrxTime'] = trxTime;
    _data['Status'] = status;
    _data['TotalUnit'] = totalUnit;
    return _data;
  }
}
