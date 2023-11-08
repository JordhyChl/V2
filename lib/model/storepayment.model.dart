// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_void_to_null

class StorePaymentModel {
  StorePaymentModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final Data data;

  StorePaymentModel.fromJson(Map<String, dynamic> json) {
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
    required this.transactionId,
    required this.orderId,
    required this.grossAmount,
    required this.paymentType,
    required this.transactionTime,
    required this.transactionStatus,
    required this.fraudStatus,
    required this.maskedCard,
    required this.statusCode,
    required this.bank,
    required this.statusMessage,
    required this.approvalCode,
    required this.channelResponseCode,
    required this.channelResponseMessage,
    required this.currency,
    required this.cardType,
    required this.redirectUrl,
    required this.id,
    this.validationMessages,
    required this.installmentTerm,
    required this.eci,
    required this.savedTokenId,
    required this.savedTokenIdExpiredAt,
    required this.pointRedeemAmount,
    required this.pointRedeemQuantity,
    required this.pointBalanceAmount,
    required this.permataVaNumber,
    this.vaNumbers,
    required this.billKey,
    required this.billerCode,
    required this.acquirer,
    this.actions,
    required this.paymentCode,
    required this.store,
    required this.qrString,
    required this.onUs,
  });
  late final String transactionId;
  late final String orderId;
  late final String grossAmount;
  late final String paymentType;
  late final String transactionTime;
  late final String transactionStatus;
  late final String fraudStatus;
  late final String maskedCard;
  late final String statusCode;
  late final String bank;
  late final String statusMessage;
  late final String approvalCode;
  late final String channelResponseCode;
  late final String channelResponseMessage;
  late final String currency;
  late final String cardType;
  late final String redirectUrl;
  late final String id;
  late final Null validationMessages;
  late final String installmentTerm;
  late final String eci;
  late final String savedTokenId;
  late final String savedTokenIdExpiredAt;
  late final int pointRedeemAmount;
  late final int pointRedeemQuantity;
  late final String pointBalanceAmount;
  late final String permataVaNumber;
  late final Null vaNumbers;
  late final String billKey;
  late final String billerCode;
  late final String acquirer;
  late final Null actions;
  late final String paymentCode;
  late final String store;
  late final String qrString;
  late final bool onUs;

  Data.fromJson(Map<String, dynamic> json) {
    transactionId = json['transaction_id'];
    orderId = json['order_id'];
    grossAmount = json['gross_amount'];
    paymentType = json['payment_type'];
    transactionTime = json['transaction_time'];
    transactionStatus = json['transaction_status'];
    fraudStatus = json['fraud_status'];
    maskedCard = json['masked_card'];
    statusCode = json['status_code'];
    bank = json['bank'];
    statusMessage = json['status_message'];
    approvalCode = json['approval_code'];
    channelResponseCode = json['channel_response_code'];
    channelResponseMessage = json['channel_response_message'];
    currency = json['currency'];
    cardType = json['card_type'];
    redirectUrl = json['redirect_url'];
    id = json['id'];
    validationMessages = null;
    installmentTerm = json['installment_term'];
    eci = json['eci'];
    savedTokenId = json['saved_token_id'];
    savedTokenIdExpiredAt = json['saved_token_id_expired_at'];
    pointRedeemAmount = json['point_redeem_amount'];
    pointRedeemQuantity = json['point_redeem_quantity'];
    pointBalanceAmount = json['point_balance_amount'];
    permataVaNumber = json['permata_va_number'];
    vaNumbers = null;
    billKey = json['bill_key'];
    billerCode = json['biller_code'];
    acquirer = json['acquirer'];
    actions = null;
    paymentCode = json['payment_code'];
    store = json['store'];
    qrString = json['qr_string'];
    onUs = json['on_us'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['transaction_id'] = transactionId;
    _data['order_id'] = orderId;
    _data['gross_amount'] = grossAmount;
    _data['payment_type'] = paymentType;
    _data['transaction_time'] = transactionTime;
    _data['transaction_status'] = transactionStatus;
    _data['fraud_status'] = fraudStatus;
    _data['masked_card'] = maskedCard;
    _data['status_code'] = statusCode;
    _data['bank'] = bank;
    _data['status_message'] = statusMessage;
    _data['approval_code'] = approvalCode;
    _data['channel_response_code'] = channelResponseCode;
    _data['channel_response_message'] = channelResponseMessage;
    _data['currency'] = currency;
    _data['card_type'] = cardType;
    _data['redirect_url'] = redirectUrl;
    _data['id'] = id;
    _data['validation_messages'] = validationMessages;
    _data['installment_term'] = installmentTerm;
    _data['eci'] = eci;
    _data['saved_token_id'] = savedTokenId;
    _data['saved_token_id_expired_at'] = savedTokenIdExpiredAt;
    _data['point_redeem_amount'] = pointRedeemAmount;
    _data['point_redeem_quantity'] = pointRedeemQuantity;
    _data['point_balance_amount'] = pointBalanceAmount;
    _data['permata_va_number'] = permataVaNumber;
    _data['va_numbers'] = vaNumbers;
    _data['bill_key'] = billKey;
    _data['biller_code'] = billerCode;
    _data['acquirer'] = acquirer;
    _data['actions'] = actions;
    _data['payment_code'] = paymentCode;
    _data['store'] = store;
    _data['qr_string'] = qrString;
    _data['on_us'] = onUs;
    return _data;
  }
}
