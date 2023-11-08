class ErrorTrapModel {
  ErrorTrapModel({
    required this.isError,
    required this.requestSent,
    required this.statusError,
    required this.bodyError,
  });
  late final bool isError;
  late final String requestSent;
  late final String statusError;
  late final String bodyError;

  ErrorTrapModel.fromJson(Map<String, dynamic> json) {
    isError = json['isError'];
    requestSent = json['requestSent'];
    statusError = json['statusError'];
    bodyError = json['bodyError'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['isError'] = isError;
    data['requestSent'] = requestSent;
    data['statusError'] = statusError;
    data['bodyError'] = bodyError;
    return data;
  }
}
