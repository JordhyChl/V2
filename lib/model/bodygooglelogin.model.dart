// ignore_for_file: no_leading_underscores_for_local_identifiers

class BodyLoginGoogle {
  BodyLoginGoogle({
    required this.email,
    required this.googleid,
    required this.fcmToken,
  });
  late final String email;
  late final String googleid;
  late final String fcmToken;

  BodyLoginGoogle.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    googleid = json['google_id'];
    fcmToken = json['fcm_token'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['email'] = email;
    _data['google_id'] = googleid;
    _data['fcm_token'] = fcmToken;
    return _data;
  }
}
