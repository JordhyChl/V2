import 'package:flutter/material.dart';

class ListProduk {
  String imageUrl;
  String name;
  String desc;
  Widget navigasi;

  ListProduk(
      {required this.imageUrl,
      required this.name,
      required this.desc,
      required this.navigasi});
}
