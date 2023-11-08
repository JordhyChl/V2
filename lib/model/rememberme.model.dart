// ignore_for_file: non_constant_identifier_names

class RememberMe {
  RememberMe({
    required this.Username,
    required this.Password,
  });
  late final String Username;
  late final String Password;

  RememberMe.fromJson(Map<String, dynamic> json) {
    Username = json['Username'];
    Password = json['Password'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['Username'] = Username;
    data['Password'] = Password;
    return data;
  }
}
