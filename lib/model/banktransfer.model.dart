// ignore_for_file: no_leading_underscores_for_local_identifiers

class BankTransfer {
  BankTransfer({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final Data data;

  BankTransfer.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = Data.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class Data {
  Data({
    required this.detail,
    required this.grossAmount,
    required this.orderId,
    required this.paymentType,
    required this.expireIn,
    required this.npwpName,
    required this.npwpNo,
    required this.totalUnit,
    required this.transactionTime,
    required this.vehicleDetail,
  });
  late final Detail detail;
  late final String grossAmount;
  late final String orderId;
  late final String paymentType;
  late final int expireIn;
  late final String npwpName;
  late final String npwpNo;
  late final int totalUnit;
  late final int transactionTime;
  late final List<VehicleDetailTransaction> vehicleDetail;

  Data.fromJson(Map<String, dynamic> json) {
    detail = Detail.fromJson(json['detail']);
    grossAmount = json['gross_amount'];
    orderId = json['order_id'];
    paymentType = json['payment_type'];
    expireIn = json['expiry_in'];
    npwpName = json['npwp_name'];
    npwpNo = json['npwp_no'];
    totalUnit = json['total_unit'];
    transactionTime = json['transaction_time_ephoc'];
    vehicleDetail = List.from(json['detail_vehicles'])
        .map((e) => VehicleDetailTransaction.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['detail'] = detail.toJson();
    _data['gross_amount'] = grossAmount;
    _data['order_id'] = orderId;
    _data['payment_type'] = paymentType;
    _data['expiry_in'] = expireIn;
    _data['npwp_name'] = npwpName;
    _data['npwp_no'] = npwpNo;
    _data['total_unit'] = totalUnit;
    _data['transaction_time_ephoc'] = transactionTime;
    _data['data'] = vehicleDetail.map((e) => e.toJson()).toList();
    return _data;
  }
}

class VehicleDetailTransaction {
  VehicleDetailTransaction({
    required this.vehicleType,
    required this.vehicleStatus,
    required this.plate,
    required this.simcard,
    required this.package,
    required this.amount,
  });
  late final String vehicleType;
  late final String vehicleStatus;
  late final String plate;
  late final String simcard;
  late final String package;
  late final int amount;

  VehicleDetailTransaction.fromJson(Map<String, dynamic> json) {
    vehicleType = json['vehicle_type'];
    vehicleStatus = json['vehicle_status'];
    plate = json['plate'];
    simcard = json['simcard'];
    package = json['package'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['vehicle_type'] = vehicleType;
    _data['vehicle_status'] = vehicleStatus;
    _data['plate'] = plate;
    _data['simcard'] = simcard;
    _data['package'] = package;
    _data['amount'] = amount;
    return _data;
  }
}

class Detail {
  Detail({
    required this.bankName,
    required this.expiredAt,
    required this.vaNumber,
  });
  late final String bankName;
  late final String expiredAt;
  late final String vaNumber;

  Detail.fromJson(Map<String, dynamic> json) {
    bankName = json['bank_name'];
    expiredAt = json['expired_at'];
    vaNumber = json['va_number'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['bank_name'] = bankName;
    _data['expired_at'] = expiredAt;
    _data['va_number'] = vaNumber;
    return _data;
  }
}
