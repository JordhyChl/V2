// ignore_for_file: no_leading_underscores_for_local_identifiers

class RecurringStatusDetailModel {
  RecurringStatusDetailModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataRecurringStatusDetailModel data;

  RecurringStatusDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataRecurringStatusDetailModel.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataRecurringStatusDetailModel {
  DataRecurringStatusDetailModel({
    required this.orderId,
    required this.transactionDate,
    required this.status,
    required this.totalPrice,
    required this.detailUnit,
  });
  late final String orderId;
  late final String transactionDate;
  late final String status;
  late final int totalPrice;
  late final List<UnitDetail> detailUnit;

  DataRecurringStatusDetailModel.fromJson(Map<String, dynamic> json) {
    orderId = json['OrderId'];
    transactionDate = json['TransactionDate'];
    status = json['Status'];
    totalPrice = json['TotalPrice'];
    detailUnit = List.from(json['DetailUnit'])
        .map((e) => UnitDetail.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['OrderId'] = orderId;
    _data['TransactionDate'] = transactionDate;
    _data['Status'] = status;
    _data['TotalPrice'] = totalPrice;
    _data['DetailUnit'] = detailUnit.map((e) => e.toJson()).toList();
    return _data;
  }
}

class UnitDetail {
  UnitDetail({
    required this.orderId,
    required this.plate,
    required this.noGsm,
    required this.package,
    required this.price,
    required this.expired,
    required this.nextExpired,
    required this.recurringDetail,
  });
  late final String orderId;
  late final String plate;
  late final String noGsm;
  late final String package;
  late final int price;
  late final String expired;
  late final String nextExpired;
  late final DetailRecurringStatus recurringDetail;

  UnitDetail.fromJson(Map<String, dynamic> json) {
    orderId = json['OrderId'];
    plate = json['Plate'];
    noGsm = json['NoGsm'];
    package = json['Package'];
    price = json['Price'];
    expired = json['Expired'];
    nextExpired = json['NextExpired'];
    recurringDetail = DetailRecurringStatus.fromJson(json['RecurringDetail']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['OrderId'] = orderId;
    _data['Plate'] = plate;
    _data['NoGsm'] = noGsm;
    _data['Package'] = package;
    _data['Price'] = price;
    _data['Expired'] = expired;
    _data['NextExpired'] = nextExpired;
    _data['RecurringDetail'] = recurringDetail.toJson();
    return _data;
  }
}

class DetailRecurringStatus {
  DetailRecurringStatus({
    required this.amount,
    required this.chargeImmediately,
    required this.created,
    required this.creditCardToken,
    required this.currency,
    required this.description,
    required this.externalId,
    required this.id,
    required this.interval,
    required this.intervalCount,
    required this.lastCreatedInvoiceUrl,
    required this.missedPaymentAction,
    required this.payerEmail,
    required this.recharge,
    required this.recurrenceProgress,
    required this.reminderTime,
    required this.reminderTimeUnit,
    required this.shouldSendEmail,
    required this.startDate,
    required this.status,
    required this.updated,
    required this.userId,
  });
  late final int amount;
  late final bool chargeImmediately;
  late final String created;
  late final String creditCardToken;
  late final String currency;
  late final String description;
  late final String externalId;
  late final String id;
  late final String interval;
  late final int intervalCount;
  late final String lastCreatedInvoiceUrl;
  late final String missedPaymentAction;
  late final String payerEmail;
  late final bool recharge;
  late final int recurrenceProgress;
  late final int reminderTime;
  late final String reminderTimeUnit;
  late final bool shouldSendEmail;
  late final String startDate;
  late final String status;
  late final String updated;
  late final String userId;

  DetailRecurringStatus.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    chargeImmediately = json['charge_immediately'];
    created = json['created'];
    creditCardToken = json['credit_card_token'];
    currency = json['currency'];
    description = json['description'];
    externalId = json['external_id'];
    id = json['id'];
    interval = json['interval'];
    intervalCount = json['interval_count'];
    lastCreatedInvoiceUrl = json['last_created_invoice_url'];
    missedPaymentAction = json['missed_payment_action'];
    payerEmail = json['payer_email'];
    recharge = json['recharge'];
    recurrenceProgress = json['recurrence_progress'];
    reminderTime = json['reminder_time'];
    reminderTimeUnit = json['reminder_time_unit'];
    shouldSendEmail = json['should_send_email'];
    startDate = json['start_date'];
    status = json['status'];
    updated = json['updated'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['amount'] = amount;
    _data['charge_immediately'] = chargeImmediately;
    _data['created'] = created;
    _data['credit_card_token'] = creditCardToken;
    _data['currency'] = currency;
    _data['description'] = description;
    _data['external_id'] = externalId;
    _data['id'] = id;
    _data['interval'] = interval;
    _data['interval_count'] = intervalCount;
    _data['last_created_invoice_url'] = lastCreatedInvoiceUrl;
    _data['missed_payment_action'] = missedPaymentAction;
    _data['payer_email'] = payerEmail;
    _data['recharge'] = recharge;
    _data['recurrence_progress'] = recurrenceProgress;
    _data['reminder_time'] = reminderTime;
    _data['reminder_time_unit'] = reminderTimeUnit;
    _data['should_send_email'] = shouldSendEmail;
    _data['start_date'] = startDate;
    _data['status'] = status;
    _data['updated'] = updated;
    _data['user_id'] = userId;
    return _data;
  }
}
