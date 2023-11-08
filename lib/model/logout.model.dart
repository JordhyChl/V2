// ignore_for_file: no_leading_underscores_for_local_identifiers

class LogoutModel {
  LogoutModel({
    required this.status,
    required this.message,
  });
  late final bool status;
  late final String message;

  LogoutModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    return _data;
  }
}
