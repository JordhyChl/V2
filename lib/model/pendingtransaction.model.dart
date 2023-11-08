// ignore_for_file: no_leading_underscores_for_local_identifiers

class PendingModel {
  PendingModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final List<Data> data;

  PendingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = List.from(json['data']).map((e) => Data.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Data {
  Data({
    required this.orderId,
    required this.transactionTime,
    required this.expiryIn,
    required this.totalAmount,
    required this.totalUnit,
  });
  late final String orderId;
  late final int transactionTime;
  int expiryIn = 0;
  late final String totalAmount;
  late final int totalUnit;

  Data.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    transactionTime = json['transaction_time'];
    expiryIn = json['expiry_in'];
    totalAmount = json['total_amount'];
    totalUnit = json['total_unit'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['order_id'] = orderId;
    _data['transaction_time'] = transactionTime;
    _data['expiry_in'] = expiryIn;
    _data['total_amount'] = totalAmount;
    _data['total_unit'] = totalUnit;
    return _data;
  }
}
