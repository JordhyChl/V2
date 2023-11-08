// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:gpsid/theme.dart';
import 'package:gpsid/model/produk_list.dart';

class ProdukListCard extends StatelessWidget {
  final ListProduk produkList;

  const ProdukListCard(this.produkList, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        border: Border.all(width: 1.5, color: greyColor),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  blueGradientSecondary1,
                  blueGradientSecondary2,
                ],
              ),
            ),
            width: 120,
            child: Image.asset(
              produkList.imageUrl,
              width: 96,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produkList.name,
                  style: bold.copyWith(
                    fontSize: 14,
                    color: blackPrimary,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  produkList.desc,
                  style: reguler.copyWith(
                    fontSize: 10,
                    color: blackSecondary2,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => produkList.navigasi)),
                      child: Row(
                        children: [
                          Text(
                            'Lihat selengkapnya',
                            style: reguler.copyWith(
                              fontSize: 10,
                              color: bluePrimary,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: bluePrimary,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
