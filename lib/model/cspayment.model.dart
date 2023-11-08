// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:gpsid/model/banktransfer.model.dart';

class CSPaymentModel {
  CSPaymentModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final Data data;

  CSPaymentModel.fromJson(Map<String, dynamic> json) {
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

class Detail {
  Detail({
    required this.expiredAt,
    required this.paymentCode,
    required this.store,
  });
  late final String expiredAt;
  late final String paymentCode;
  late final String store;

  Detail.fromJson(Map<String, dynamic> json) {
    expiredAt = json['expired_at'];
    paymentCode = json['payment_code'];
    store = json['store'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['expired_at'] = expiredAt;
    _data['payment_code'] = paymentCode;
    _data['store'] = store;
    return _data;
  }
}
