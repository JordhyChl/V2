// ignore_for_file: no_leading_underscores_for_local_identifiers

class ProductModel {
  ProductModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataProduct data;

  ProductModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataProduct.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataProduct {
  DataProduct({
    required this.totalAllData,
    required this.currentPage,
    required this.perPage,
    required this.totalPage,
    required this.resultProduct,
  });
  late final int totalAllData;
  late final int currentPage;
  late final int perPage;
  late final int totalPage;
  late final List<ResultProduct> resultProduct;

  DataProduct.fromJson(Map<String, dynamic> json) {
    totalAllData = json['TotalAllData'];
    currentPage = json['CurrentPage'];
    perPage = json['PerPage'];
    totalPage = json['TotalPage'];
    resultProduct = List.from(json['Result'])
        .map((e) => ResultProduct.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['TotalAllData'] = totalAllData;
    _data['CurrentPage'] = currentPage;
    _data['PerPage'] = perPage;
    _data['TotalPage'] = totalPage;
    _data['Result'] = resultProduct.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ResultProduct {
  ResultProduct({
    required this.iD,
    required this.name,
    required this.description,
    required this.picture,
  });
  late final int iD;
  late final String name;
  late final String description;
  late final String picture;

  ResultProduct.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    name = json['Name'];
    description = json['Description'];
    picture = json['Picture'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['ID'] = iD;
    _data['Name'] = name;
    _data['Description'] = description;
    _data['Picture'] = picture;
    return _data;
  }
}
