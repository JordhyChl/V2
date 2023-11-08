// ignore_for_file: no_leading_underscores_for_local_identifiers

class RecStatusList {
  RecStatusList({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataRecurringStatusList data;

  RecStatusList.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataRecurringStatusList.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataRecurringStatusList {
  DataRecurringStatusList({
    required this.totalAllData,
    // required this.currentPage,
    // required this.perPage,
    // required this.totalPage,
    required this.result,
  });
  late final int totalAllData;
  // late final int currentPage;
  // late final int perPage;
  // late final int totalPage;
  late final List<ResultRecurringStatusList> result;

  DataRecurringStatusList.fromJson(Map<String, dynamic> json) {
    totalAllData = json['TotalAllData'];
    // currentPage = json['CurrentPage'];
    // perPage = json['PerPage'];
    // totalPage = json['TotalPage'];
    result = List.from(json['result'] ?? {})
        .map((e) => ResultRecurringStatusList.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['TotalAllData'] = totalAllData;
    // _data['CurrentPage'] = currentPage;
    // _data['PerPage'] = perPage;
    // _data['TotalPage'] = totalPage;
    _data['result'] = result.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ResultRecurringStatusList {
  ResultRecurringStatusList({
    required this.orderId,
    required this.package,
    required this.status,
    required this.totalUnit,
    required this.totalPrice,
    required this.transactionDate,
    required this.nextTransaction,
  });
  late final String orderId;
  late final String package;
  late final String status;
  late final int totalUnit;
  late final int totalPrice;
  late final String transactionDate;
  late final String nextTransaction;

  ResultRecurringStatusList.fromJson(Map<String, dynamic> json) {
    orderId = json['OrderId'];
    package = json['Package'];
    status = json['Status'];
    totalUnit = json['TotalUnit'];
    totalPrice = json['TotalPrice'];
    transactionDate = json['TransactionDate'];
    nextTransaction = json['NextTransaction'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['OrderId'] = orderId;
    _data['Package'] = package;
    _data['Status'] = status;
    _data['TotalUnit'] = totalUnit;
    _data['TotalPrice'] = totalPrice;
    _data['TransactionDate'] = transactionDate;
    _data['NextTransaction'] = nextTransaction;
    return _data;
  }
}
