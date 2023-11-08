// ignore_for_file: no_leading_underscores_for_local_identifiers

class ProfileModel {
  ProfileModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataProfile data;

  ProfileModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataProfile.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataProfile {
  DataProfile({
    required this.result,
  });
  late final ResultProfile result;

  DataProfile.fromJson(Map<String, dynamic> json) {
    result = ResultProfile.fromJson(json['result']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['result'] = result.toJson();
    return _data;
  }
}

class ResultProfile {
  ResultProfile({
    required this.iD,
    required this.username,
    required this.fullname,
    required this.companyName,
    required this.email,
    required this.address,
    required this.phone,
    required this.branchId,
    required this.privilage,
    required this.status,
    required this.forgotKey,
    required this.type,
    required this.remark,
    required this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
    required this.emailVerification,
    required this.isVerifiedEmail,
    required this.isVerifiedPhone,
    required this.kodeVa,
    required this.preferensiCode,
    required this.preferensi,
    required this.custType,
    required this.registerByGoogle,
    required this.registerByApple,
  });
  late final int iD;
  late final String username;
  late final String fullname;
  late final String companyName;
  late final String email;
  late final String address;
  late final String phone;
  late final int branchId;
  late final int privilage;
  late final int status;
  late final String forgotKey;
  late final int type;
  late final String remark;
  late final String lastLogin;
  late final String createdAt;
  late final String updatedAt;
  late final String emailVerification;
  late final bool isVerifiedEmail;
  late final bool isVerifiedPhone;
  late final String kodeVa;
  late final int preferensiCode;
  late final String preferensi;
  late final int custType;
  late final bool registerByGoogle;
  late final bool registerByApple;

  ResultProfile.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    username = json['Username'];
    fullname = json['Fullname'];
    companyName = json['Company_name'];
    email = json['Email'];
    address = json['Address'];
    phone = json['Phone'];
    branchId = json['Branch_id'];
    privilage = json['Privilage'];
    status = json['Status'];
    forgotKey = json['Forgot_key'];
    type = json['Type'];
    remark = json['Remark'];
    lastLogin = json['Last_login'];
    createdAt = json['Created_at'];
    updatedAt = json['Updated_at'];
    emailVerification = json['Email_verification'];
    isVerifiedEmail = json['Is_verified_email'];
    isVerifiedPhone = json['Is_verified_phone'];
    kodeVa = json['Kode_va'];
    preferensiCode = json['Preferensi'];
    preferensi = json['PreferensiName'];
    custType = json['TypeCustomer'];
    registerByGoogle = json['RegisterByGoogle'];
    registerByApple = json['RegisterByApple'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['ID'] = iD;
    _data['Username'] = username;
    _data['Fullname'] = fullname;
    _data['Company_name'] = companyName;
    _data['Email'] = email;
    _data['Address'] = address;
    _data['Phone'] = phone;
    _data['Branch_id'] = branchId;
    _data['Privilage'] = privilage;
    _data['Status'] = status;
    _data['Forgot_key'] = forgotKey;
    _data['Type'] = type;
    _data['Remark'] = remark;
    _data['Last_login'] = lastLogin;
    _data['Created_at'] = createdAt;
    _data['Updated_at'] = updatedAt;
    _data['Email_verification'] = emailVerification;
    _data['Is_verified_email'] = isVerifiedEmail;
    _data['Is_verified_phone'] = isVerifiedPhone;
    _data['Kode_va'] = kodeVa;
    _data['Preferensi'] = preferensiCode;
    _data['PreferensiName'] = preferensi;
    _data['TypeCustomer'] = custType;
    _data['RegisterByGoogle'] = registerByGoogle;
    _data['RegisterByApple'] = registerByApple;
    return _data;
  }
}
