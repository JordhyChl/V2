// ignore_for_file: no_leading_underscores_for_local_identifiers

class BodyLogin {
  BodyLogin({
    required this.username,
    required this.password,
    required this.fcmToken,
  });
  late final String username;
  late final String password;
  late final String fcmToken;

  BodyLogin.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    password = json['password'];
    fcmToken = json['fcm_token'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['username'] = username;
    _data['password'] = password;
    _data['fcm_token'] = fcmToken;
    return _data;
  }
}
