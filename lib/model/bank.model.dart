// ignore_for_file: no_leading_underscores_for_local_identifiers

class BankCodeModel {
  BankCodeModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final Data data;

  BankCodeModel.fromJson(Map<String, dynamic> json) {
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
    required this.convenienceStore,
    required this.instantPayment,
    required this.transferBank,
  });
  late final List<ConvenienceStore> convenienceStore;
  late final List<InstantPayment> instantPayment;
  late final List<TransferBank> transferBank;

  Data.fromJson(Map<String, dynamic> json) {
    convenienceStore = List.from(json['convenience_store'])
        .map((e) => ConvenienceStore.fromJson(e))
        .toList();
    instantPayment = List.from(json['instant_payment'])
        .map((e) => InstantPayment.fromJson(e))
        .toList();
    transferBank = List.from(json['transfer_bank'])
        .map((e) => TransferBank.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['convenience_store'] =
        convenienceStore.map((e) => e.toJson()).toList();
    _data['instant_payment'] = instantPayment.map((e) => e.toJson()).toList();
    _data['transfer_bank'] = transferBank.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ConvenienceStore {
  ConvenienceStore({
    required this.bankCode,
    required this.bankName,
  });
  late final String bankCode;
  late final String bankName;

  ConvenienceStore.fromJson(Map<String, dynamic> json) {
    bankCode = json['bank_code'];
    bankName = json['bank_name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['bank_code'] = bankCode;
    _data['bank_name'] = bankName;
    return _data;
  }
}

class InstantPayment {
  InstantPayment({
    required this.bankCode,
    required this.bankName,
  });
  late final String bankCode;
  late final String bankName;

  InstantPayment.fromJson(Map<String, dynamic> json) {
    bankCode = json['bank_code'];
    bankName = json['bank_name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['bank_code'] = bankCode;
    _data['bank_name'] = bankName;
    return _data;
  }
}

class TransferBank {
  TransferBank({
    required this.bankCode,
    required this.bankName,
  });
  late final String bankCode;
  late final String bankName;

  TransferBank.fromJson(Map<String, dynamic> json) {
    bankCode = json['bank_code'];
    bankName = json['bank_name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['bank_code'] = bankCode;
    _data['bank_name'] = bankName;
    return _data;
  }
}
