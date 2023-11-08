class CheckEmailModel {
  CheckEmailModel({
    required this.status,
    required this.message,
  });
  late final bool status;
  late final List<Message> message;

  CheckEmailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message =
        List.from(json['message']).map((e) => Message.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Message {
  Message({
    required this.isVerifiedEmail,
    required this.emailVerification,
  });
  late final bool isVerifiedEmail;
  late final String emailVerification;

  Message.fromJson(Map<String, dynamic> json) {
    isVerifiedEmail = json['is_verified_email'];
    emailVerification = json['email_verification'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['is_verified_email'] = isVerifiedEmail;
    _data['email_verification'] = emailVerification;
    return _data;
  }
}
