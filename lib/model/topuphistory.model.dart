

class TopupHis {
  String? orderid;
  String? date;
  String? price;
  int? unit;
  String? status;

  TopupHis({
    required this.orderid,
    required this.date,
    required this.price,
    required this.unit,
    required this.status,
  });

  TopupHis.fromJson(Map<String, dynamic> json) {
    orderid = json['orderid'];
    date = json['date'];
    price = json['price'];
    unit = json['unit'];
    status = json['status'];
  }
}
