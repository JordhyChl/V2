// ignore_for_file: no_leading_underscores_for_local_identifiers, non_constant_identifier_names

class MessageModel {
  MessageModel({
    required this.status,
    required this.message,
    // required this.data,
  });
  late final bool status;
  late final String message;
  // late final Data data;

  MessageModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    // data = Data.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    // _data['data'] = data.toJson();
    return _data;
  }
}

class Data {
  Data({
    required this.ID,
    required this.Username,
    required this.Fullname,
    required this.Phone,
    required this.Email,
    required this.Addres,
    required this.CompanyName,
    required this.BranchId,
    required this.Privilage,
  });
  late final int ID;
  late final String Username;
  late final String Fullname;
  late final String Phone;
  late final String Email;
  late final String Addres;
  late final String CompanyName;
  late final int BranchId;
  late final int Privilage;

  Data.fromJson(Map<String, dynamic> json) {
    ID = json['ID'];
    Username = json['Username'];
    Fullname = json['Fullname'];
    Phone = json['Phone'];
    Email = json['Email'];
    Addres = json['Addres'];
    CompanyName = json['Company_name'];
    BranchId = json['Branch_id'];
    Privilage = json['Privilage'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['ID'] = ID;
    _data['Username'] = Username;
    _data['Fullname'] = Fullname;
    _data['Phone'] = Phone;
    _data['Email'] = Email;
    _data['Addres'] = Addres;
    _data['Company_name'] = CompanyName;
    _data['Branch_id'] = BranchId;
    _data['Privilage'] = Privilage;
    return _data;
  }
}
