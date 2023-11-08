// ignore_for_file: no_leading_underscores_for_local_identifiers

class PaymentNotifModel {
  PaymentNotifModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final List<DataPaymentNotif> data;

  PaymentNotifModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = List.from(json['data'] ?? [])
        .map((e) => DataPaymentNotif.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.map((e) => e.toJson()).toList();
    return _data;
  }
}

class DataPaymentNotif {
  DataPaymentNotif({
    required this.plate,
    required this.sim,
    required this.status,
    required this.typePembayaran,
    required this.harga,
    required this.jumlah,
    required this.packName,
    required this.orderId,
    required this.totalUnit,
    required this.dateInserted,
    required this.datePayment,
    required this.description,
  });
  late final String plate;
  late final String sim;
  late final String status;
  late final String typePembayaran;
  late final int harga;
  late final int jumlah;
  late final String packName;
  late final String orderId;
  late final int totalUnit;
  late final String dateInserted;
  late final String datePayment;
  late final String description;

  DataPaymentNotif.fromJson(Map<String, dynamic> json) {
    plate = json['plate'];
    sim = json['sim'];
    status = json['status'];
    typePembayaran = json['type_pembayaran'];
    harga = json['harga'];
    jumlah = json['jumlah'];
    packName = json['pack_name'];
    orderId = json['order_id'];
    totalUnit = json['total_unit'];
    dateInserted = json['date_inserted'];
    datePayment = json['date_payment'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['plate'] = plate;
    _data['sim'] = sim;
    _data['status'] = status;
    _data['type_pembayaran'] = typePembayaran;
    _data['harga'] = harga;
    _data['jumlah'] = jumlah;
    _data['pack_name'] = packName;
    _data['order_id'] = orderId;
    _data['total_unit'] = totalUnit;
    _data['date_inserted'] = dateInserted;
    _data['date_payment'] = datePayment;
    _data['description'] = description;
    return _data;
  }
}
