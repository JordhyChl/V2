// ignore_for_file: no_leading_underscores_for_local_identifiers

class LinkModel {
  LinkModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataLink data;

  LinkModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataLink.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataLink {
  DataLink({
    required this.branch,
    required this.head,
  });
  late final Branch branch;
  late final Head head;

  DataLink.fromJson(Map<String, dynamic> json) {
    branch = Branch.fromJson(json['branch']);
    head = Head.fromJson(json['head']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['branch'] = branch.toJson();
    _data['head'] = head.toJson();
    return _data;
  }
}

class Branch {
  Branch({
    required this.callUs,
    required this.whatsapp,
  });
  late final String callUs;
  late final String whatsapp;

  Branch.fromJson(Map<String, dynamic> json) {
    callUs = json['call_us'];
    whatsapp = json['whatsapp'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['call_us'] = callUs;
    _data['whatsapp'] = whatsapp;
    return _data;
  }
}

class Head {
  Head({
    required this.callUs,
    required this.aboutUs,
    required this.faq,
    required this.terms,
    required this.whatsapp,
  });
  late final String callUs;
  late final String aboutUs;
  late final String faq;
  late final String terms;
  late final String whatsapp;

  Head.fromJson(Map<String, dynamic> json) {
    callUs = json['call_us'];
    aboutUs = json['about_us'];
    faq = json['faq'];
    terms = json['terms'];
    whatsapp = json['whatsapp'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['call_us'] = callUs;
    _data['about_us'] = aboutUs;
    _data['faq'] = faq;
    _data['terms'] = terms;
    _data['whatsapp'] = whatsapp;
    return _data;
  }
}
