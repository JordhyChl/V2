class RecurringHis {
  String? payment;
  int? package;
  int? unit;
  String? price;
  String? status;

  RecurringHis({
    required this.payment,
    required this.package,
    required this.unit,
    required this.price,
    required this.status,
  });

  RecurringHis.fromJson(Map<String, dynamic> json) {
    payment = json['payment'];
    package = json['package'];
    unit = json['unit'];
    price = json['price'];
    status = json['status'];
  }
}
