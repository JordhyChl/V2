// ignore_for_file: no_leading_underscores_for_local_identifiers

class TopUpHistDetailModel {
  TopUpHistDetailModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataTopupHistDetail data;

  TopUpHistDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataTopupHistDetail.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataTopupHistDetail {
  DataTopupHistDetail({
    required this.result,
  });
  late final ResultTopupHistDetail result;

  DataTopupHistDetail.fromJson(Map<String, dynamic> json) {
    result = ResultTopupHistDetail.fromJson(json['result']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['result'] = result.toJson();
    return _data;
  }
}

class ResultTopupHistDetail {
  ResultTopupHistDetail({
    required this.orderId,
    required this.paymentType,
    required this.virtualAccount,
    required this.totalPrice,
    required this.paymentVia,
    required this.trxDate,
    required this.trxTime,
    required this.status,
    required this.sim,
    required this.expired,
    required this.nextExpired,
    required this.information,
    required this.topUpPackageId,
    required this.totalUnit,
    required this.cartDetail,
    required this.npwpNo,
    required this.npwpName,
    required this.npwpAddr,
    required this.npwpEmail,
    required this.npwpWA,
    required this.statusNpwp,
  });
  late final String orderId;
  late final String paymentType;
  late final String virtualAccount;
  late final int totalPrice;
  late final String paymentVia;
  late final String trxDate;
  late final String trxTime;
  late final String status;
  late final String sim;
  late final String expired;
  late final String nextExpired;
  late final String information;
  late final int topUpPackageId;
  late final int totalUnit;
  late final List<CartDetail> cartDetail;
  late final String npwpNo;
  late final String npwpName;
  late final String npwpAddr;
  late final String npwpEmail;
  late final String npwpWA;
  late final String statusNpwp;

  ResultTopupHistDetail.fromJson(Map<String, dynamic> json) {
    orderId = json['OrderId'];
    paymentType = json['PaymentType'];
    virtualAccount = json['VirtualAccount'];
    totalPrice = json['TotalPrice'];
    paymentVia = json['PaymentVia'];
    trxDate = json['TrxDate'];
    trxTime = json['TrxTime'];
    status = json['Status'];
    sim = json['Sim'];
    expired = json['Expired'];
    nextExpired = json['NextExpired'];
    information = json['Information'];
    topUpPackageId = json['TopUpPackageId'];
    totalUnit = json['TotalUnit'];
    cartDetail = List.from(json['CartDetail'])
        .map((e) => CartDetail.fromJson(e))
        .toList();
    npwpNo = json['npwp_no'];
    npwpName = json['npwp_name'];
    npwpAddr = json['npwp_addr'];
    npwpEmail = json['npwp_email'];
    npwpWA = json['npwp_wa'];
    statusNpwp = json['status_npwp'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['OrderId'] = orderId;
    _data['PaymentType'] = paymentType;
    _data['VirtualAccount'] = virtualAccount;
    _data['TotalPrice'] = totalPrice;
    _data['PaymentVia'] = paymentVia;
    _data['TrxDate'] = trxDate;
    _data['TrxTime'] = trxTime;
    _data['Status'] = status;
    _data['Sim'] = sim;
    _data['Expired'] = expired;
    _data['NextExpired'] = nextExpired;
    _data['Information'] = information;
    _data['TopUpPackageId'] = topUpPackageId;
    _data['TotalUnit'] = totalUnit;
    _data['CartDetail'] = cartDetail.map((e) => e.toJson()).toList();
    _data['npwp_no'] = npwpNo;
    _data['npwp_name'] = npwpName;
    _data['npwp_addr'] = npwpAddr;
    _data['npwp_email'] = npwpEmail;
    _data['npwp_wa'] = npwpWA;
    _data['status_npwp'] = statusNpwp;
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

class NpwpDetail {
  NpwpDetail({
    required this.npwpNo,
    required this.npwpName,
    required this.npwpAddr,
    required this.npwpEmail,
    required this.npwpWa,
    required this.status,
  });
  late final String npwpNo;
  late final String npwpName;
  late final String npwpAddr;
  late final String npwpEmail;
  late final String npwpWa;
  late final String status;

  NpwpDetail.fromJson(Map<String, dynamic> json) {
    npwpNo = json['npwp_no'];
    npwpName = json['npwp_name'];
    npwpAddr = json['npwp_addr'];
    npwpEmail = json['npwp_email'];
    npwpWa = json['npwp_wa'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['npwp_no'] = npwpNo;
    _data['npwp_name'] = npwpName;
    _data['npwp_addr'] = npwpAddr;
    _data['npwp_email'] = npwpEmail;
    _data['npwp_wa'] = npwpWa;
    _data['status'] = status;
    return _data;
  }
}
