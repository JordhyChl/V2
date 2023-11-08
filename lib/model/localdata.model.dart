// ignore_for_file: non_constant_identifier_names

class LocalData {
  LocalData(
      {required this.ID,
      required this.SeenId,
      required this.Username,
      required this.Password,
      required this.Fullname,
      required this.Phone,
      required this.Email,
      required this.Addres,
      required this.CompanyName,
      required this.BranchId,
      required this.Privilage,
      required this.Token,
      required this.IsGoogle,
      required this.IsApple,
      required this.IsGenerated,
      required this.createdAt});
  late final int ID;
  late final int SeenId;
  late final String Username;
  late final String Password;
  late final String Fullname;
  late final String Phone;
  late final String Email;
  late final String Addres;
  late final String CompanyName;
  late final int BranchId;
  late final int Privilage;
  late final String Token;
  late final bool IsGenerated;
  late final bool IsGoogle;
  late final bool IsApple;
  late final String createdAt;

  LocalData.fromJson(Map<String, dynamic> json) {
    ID = json['ID'];
    SeenId = json['Seen_id'];
    Username = json['Username'];
    Password = json['Password'];
    Fullname = json['Fullname'];
    Phone = json['Phone'];
    Email = json['Email'];
    Addres = json['Addres'];
    CompanyName = json['Company_name'];
    BranchId = json['Branch_id'];
    Privilage = json['Privilage'];
    Token = json['Token'];
    IsGenerated = json['IsGenerated'];
    IsGoogle = json['IsGoogle'];
    IsApple = json['IsApple'];
    createdAt = json['Created_at'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ID'] = ID;
    data['Seen_id'] = SeenId;
    data['Username'] = Username;
    data['Password'] = Password;
    data['Fullname'] = Fullname;
    data['Phone'] = Phone;
    data['Email'] = Email;
    data['Addres'] = Addres;
    data['Company_name'] = CompanyName;
    data['Branch_id'] = BranchId;
    data['Privilage'] = Privilage;
    data['Token'] = Token;
    data['IsGenerated'] = IsGenerated;
    data['IsGoogle'] = IsGoogle;
    data['IsApple'] = IsApple;
    data['Created_at'] = createdAt;
    return data;
  }
}
