// ignore_for_file: no_leading_underscores_for_local_identifiers, non_constant_identifier_names

class RecHistList {
  RecHistList({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataRecurringHistList data;

  RecHistList.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataRecurringHistList.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataRecurringHistList {
  DataRecurringHistList({
    required this.TotalAllData,
    required this.result,
  });
  late final int TotalAllData;
  late final List<ResultRecurringHistList> result;

  DataRecurringHistList.fromJson(Map<String, dynamic> json) {
    TotalAllData = json['TotalAllData'];
    result = List.from(json['result'] ?? [])
        .map((e) => ResultRecurringHistList.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['TotalAllData'] = TotalAllData;
    _data['result'] = result.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ResultRecurringHistList {
  ResultRecurringHistList({
    required this.orderId,
    required this.status,
    required this.totalPrice,
    required this.typePembayaran,
    required this.transactionDate,
    required this.expired,
    required this.nextExpired,
    required this.totalUnit,
    required this.packNmame,
  });
  late final String orderId;
  late final String status;
  late final int totalPrice;
  late final String typePembayaran;
  late final String transactionDate;
  late final String expired;
  late final String nextExpired;
  late final int totalUnit;
  late final String packNmame;

  ResultRecurringHistList.fromJson(Map<String, dynamic> json) {
    orderId = json['OrderId'];
    status = json['Status'];
    totalPrice = json['TotalPrice'];
    typePembayaran = json['TypePembayaran'];
    transactionDate = json['TransactionDate'];
    expired = json['Expired'];
    nextExpired = json['NextExpired'];
    totalUnit = json['TotalUnit'];
    packNmame = json['Pack_name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['OrderId'] = orderId;
    _data['Status'] = status;
    _data['TotalPrice'] = totalPrice;
    _data['TypePembayaran'] = typePembayaran;
    _data['TransactionDate'] = transactionDate;
    _data['Expired'] = expired;
    _data['NextExpired'] = nextExpired;
    _data['TotalUnit'] = totalUnit;
    _data['Pack_name'] = packNmame;
    return _data;
  }
}
