// ignore_for_file: no_leading_underscores_for_local_identifiers, non_constant_identifier_names

class LoginModel {
  LoginModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataLogin data;

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataLogin.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataLogin {
  DataLogin(
      {required this.ID,
      required this.Username,
      required this.SeenId,
      required this.Fullname,
      required this.Phone,
      required this.Email,
      required this.Addres,
      required this.CompanyName,
      required this.BranchId,
      required this.Privilage,
      required this.Token,
      required this.isGenerated,
      required this.IsGoogle,
      required this.IsApple,
      required this.createdAt});
  late final int ID;
  late final String Username;
  late final int SeenId;
  late final String Fullname;
  late final String Phone;
  late final String Email;
  late final String Addres;
  late final String CompanyName;
  late final int BranchId;
  late final int Privilage;
  late final String Token;
  late final bool isGenerated;
  late final bool IsGoogle;
  late final bool IsApple;
  late final String createdAt;

  DataLogin.fromJson(Map<String, dynamic> json) {
    ID = json['ID'];
    Username = json['Username'];
    SeenId = json['Seen_id'];
    Fullname = json['Fullname'];
    Phone = json['Phone'];
    Email = json['Email'];
    Addres = json['Addres'];
    CompanyName = json['Company_name'];
    BranchId = json['Branch_id'];
    Privilage = json['Privilage'];
    Token = json['Token'];
    isGenerated = json['IsGenerated'];
    IsGoogle = json['IsGoogle'];
    IsApple = json['IsApple'];
    createdAt = json['Created_at'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['ID'] = ID;
    _data['Username'] = Username;
    _data['Seen_id'] = SeenId;
    _data['Fullname'] = Fullname;
    _data['Phone'] = Phone;
    _data['Email'] = Email;
    _data['Addres'] = Addres;
    _data['Company_name'] = CompanyName;
    _data['Branch_id'] = BranchId;
    _data['Privilage'] = Privilage;
    _data['Token'] = Token;
    _data['IsGenerated'] = isGenerated;
    _data['IsGoogle'] = IsGoogle;
    _data['IsApple'] = IsApple;
    _data['Created_at'] = createdAt;
    return _data;
  }
}
