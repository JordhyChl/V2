// ignore_for_file: no_leading_underscores_for_local_identifiers

class RecurringHistDetailModel {
  RecurringHistDetailModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final Data data;

  RecurringHistDetailModel.fromJson(Map<String, dynamic> json) {
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
    required this.result,
  });
  late final ResultHistDetail result;

  Data.fromJson(Map<String, dynamic> json) {
    result = ResultHistDetail.fromJson(json['result']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['result'] = result.toJson();
    return _data;
  }
}

class ResultHistDetail {
  ResultHistDetail({
    required this.orderId,
    required this.sim,
    required this.expired,
    required this.nextExpired,
    required this.username,
    required this.information,
    required this.harga,
    required this.status,
    required this.domain,
    required this.via,
    required this.typePembayaran,
    required this.recurringDetail,
    required this.totalUnit,
    required this.cartDetail,
  });
  late final String orderId;
  late final String sim;
  late final String expired;
  late final String nextExpired;
  late final String username;
  late final String information;
  late final String harga;
  late final String status;
  late final String domain;
  late final String via;
  late final String typePembayaran;
  late final RecurringDetail recurringDetail;
  late final int totalUnit;
  late final List<CartDetail> cartDetail;

  ResultHistDetail.fromJson(Map<String, dynamic> json) {
    orderId = json['OrderId'];
    sim = json['Sim'];
    expired = json['Expired'];
    nextExpired = json['NextExpired'];
    username = json['Username'];
    information = json['Information'];
    harga = json['Harga'];
    status = json['Status'];
    domain = json['Domain'];
    via = json['Via'];
    typePembayaran = json['TypePembayaran'];
    recurringDetail = RecurringDetail.fromJson(json['RecurringDetail']);
    totalUnit = json['TotalUnit'];
    cartDetail = List.from(json['CartDetail'])
        .map((e) => CartDetail.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['OrderId'] = orderId;
    _data['Sim'] = sim;
    _data['Expired'] = expired;
    _data['NextExpired'] = nextExpired;
    _data['Username'] = username;
    _data['Information'] = information;
    _data['Harga'] = harga;
    _data['Status'] = status;
    _data['Domain'] = domain;
    _data['Via'] = via;
    _data['TypePembayaran'] = typePembayaran;
    _data['RecurringDetail'] = recurringDetail.toJson();
    _data['TotalUnit'] = totalUnit;
    _data['CartDetail'] = cartDetail.map((e) => e.toJson()).toList();
    return _data;
  }
}

class RecurringDetail {
  RecurringDetail({
    // required this.adjustedReceivedAmount,
    required this.amount,
    required this.created,
    required this.creditCardChargeId,
    required this.creditCardToken,
    required this.currency,
    required this.description,
    required this.externalId,
    required this.id,
    required this.isHigh,
    required this.merchantName,
    required this.paidAmount,
    required this.paidAt,
    required this.payerEmail,
    required this.paymentChannel,
    required this.paymentMethod,
    required this.recurringPaymentId,
    required this.status,
    required this.updated,
    required this.userId,
  });
  // late final int adjustedReceivedAmount;
  late final int amount;
  late final String created;
  late final String creditCardChargeId;
  late final String creditCardToken;
  late final String currency;
  late final String description;
  late final String externalId;
  late final String id;
  late final bool isHigh;
  late final String merchantName;
  late final int paidAmount;
  late final String paidAt;
  late final String payerEmail;
  late final String paymentChannel;
  late final String paymentMethod;
  late final String recurringPaymentId;
  late final String status;
  late final String updated;
  late final String userId;

  RecurringDetail.fromJson(Map<String, dynamic> json) {
    // adjustedReceivedAmount = json['adjusted_received_amount'] ?? '';
    amount = json['amount'];
    created = json['created'];
    creditCardChargeId = json['credit_card_charge_id'];
    creditCardToken = json['credit_card_token'];
    currency = json['currency'];
    description = json['description'];
    externalId = json['external_id'];
    id = json['id'];
    isHigh = json['is_high'];
    merchantName = json['merchant_name'];
    paidAmount = json['paid_amount'];
    paidAt = json['paid_at'];
    payerEmail = json['payer_email'];
    paymentChannel = json['payment_channel'];
    paymentMethod = json['payment_method'];
    recurringPaymentId = json['recurring_payment_id'];
    status = json['status'];
    updated = json['updated'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    // _data['adjusted_received_amount'] = adjustedReceivedAmount;
    _data['amount'] = amount;
    _data['created'] = created;
    _data['credit_card_charge_id'] = creditCardChargeId;
    _data['credit_card_token'] = creditCardToken;
    _data['currency'] = currency;
    _data['description'] = description;
    _data['external_id'] = externalId;
    _data['id'] = id;
    _data['is_high'] = isHigh;
    _data['merchant_name'] = merchantName;
    _data['paid_amount'] = paidAmount;
    _data['paid_at'] = paidAt;
    _data['payer_email'] = payerEmail;
    _data['payment_channel'] = paymentChannel;
    _data['payment_method'] = paymentMethod;
    _data['recurring_payment_id'] = recurringPaymentId;
    _data['status'] = status;
    _data['updated'] = updated;
    _data['user_id'] = userId;
    return _data;
  }
}

class CartDetail {
  CartDetail({
    required this.platNomor,
    required this.nomorGsm,
    required this.paket,
    required this.harga,
    required this.expired,
    required this.nextExpired,
  });
  late final String platNomor;
  late final String nomorGsm;
  late final String paket;
  late final int harga;
  late final String expired;
  late final String nextExpired;

  CartDetail.fromJson(Map<String, dynamic> json) {
    platNomor = json['PlatNomor'];
    nomorGsm = json['NomorGsm'];
    paket = json['Paket'];
    harga = json['Harga'];
    expired = json['Expired'];
    nextExpired = json['NextExpired'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['PlatNomor'] = platNomor;
    _data['NomorGsm'] = nomorGsm;
    _data['Paket'] = paket;
    _data['Harga'] = harga;
    _data['Expired'] = expired;
    _data['NextExpired'] = nextExpired;
    return _data;
  }
}
