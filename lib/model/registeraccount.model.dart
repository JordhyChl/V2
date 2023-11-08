// ignore_for_file: non_constant_identifier_names

class RegisterAccountModel {
  RegisterAccountModel({
    required this.data,
  });
  late final List<DataRegister> data;

  RegisterAccountModel.fromJson(Map<String, dynamic> json) {
    data =
        List.from(json['data']).map((e) => DataRegister.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['data'] = data.map((e) => e.toJson()).toList();
    return _data;
  }
}

class DataRegister {
  DataRegister({
    required this.user,
    required this.unit,
  });
  late final UserRegister user;
  late final List<UnitRegister> unit;

  DataRegister.fromJson(Map<String, dynamic> json) {
    user = UserRegister.fromJson(json['user']);
    unit =
        List.from(json['unit']).map((e) => UnitRegister.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['user'] = user.toJson();
    _data['unit'] = unit.map((e) => e.toJson()).toList();
    return _data;
  }
}

class UserRegister {
  UserRegister({
    required this.prename,
    required this.fullname,
    required this.branch,
    required this.customerType,
    required this.phoneNumberCode,
    required this.phoneNumber,
    required this.refferal,
    required this.isAgree,
    required this.prenameco,
    required this.companyName,
    required this.isMobile,
  });
  late final String prename;
  late final String fullname;
  late final int branch;
  late final int customerType;
  late final String phoneNumberCode;
  late final String phoneNumber;
  late final String refferal;
  late final int isAgree;
  late final String prenameco;
  late final String companyName;
  late final int isMobile;

  UserRegister.fromJson(Map<String, dynamic> json) {
    prename = json['prename'];
    fullname = json['fullname'];
    branch = json['branch'];
    customerType = json['customer_type'];
    phoneNumberCode = json['phone_number_code'];
    phoneNumber = json['phone_number'];
    refferal = json['refferal'];
    isAgree = json['is_agree'];
    prenameco = json['prenameco'];
    companyName = json['company_name'];
    isMobile = json['is_mobile'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['prename'] = prename;
    _data['fullname'] = fullname;
    _data['branch'] = branch;
    _data['customer_type'] = customerType;
    _data['phone_number_code'] = phoneNumberCode;
    _data['phone_number'] = phoneNumber;
    _data['refferal'] = refferal;
    _data['is_agree'] = isAgree;
    _data['prenameco'] = prenameco;
    _data['company_name'] = companyName;
    _data['is_mobile'] = isMobile;
    return _data;
  }
}

class UnitRegister {
  UnitRegister({
    required this.imei,
    required this.gsmNumber,
    required this.plate,
    required this.vehicleName,
    required this.vehicleType,
    required this.icon,
    required this.lt_warranty,
    required this.expired_gsm,
    required this.simcard_id,
  });
  late final String imei;
  late final String gsmNumber;
  late final String plate;
  late final String vehicleName;
  late final int vehicleType;
  late final int icon;
  late final int lt_warranty;
  late final String expired_gsm;
  late final String simcard_id;

  UnitRegister.fromJson(Map<String, dynamic> json) {
    imei = json['imei'];
    gsmNumber = json['gsm_number'];
    plate = json['plate'];
    vehicleName = json['vehicle_name'];
    vehicleType = json['vehicle_type'];
    icon = json['icon'];
    lt_warranty = json['lt_warranty'];
    expired_gsm = json['expired_gsm'];
    simcard_id = json['simcard_id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['imei'] = imei;
    _data['gsm_number'] = gsmNumber;
    _data['plate'] = plate;
    _data['vehicle_name'] = vehicleName;
    _data['vehicle_type'] = vehicleType;
    _data['icon'] = icon;
    _data['lt_warranty'] = lt_warranty;
    _data['expired_gsm'] = expired_gsm;
    _data['simcard_id'] = simcard_id;
    return _data;
  }
}
