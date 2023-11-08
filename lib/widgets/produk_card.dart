import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/theme.dart';
import 'package:gpsid/model/produk.dart';

class ProdukCard extends StatelessWidget {
  final Produk produk;

  const ProdukCard(this.produk, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            blueGradient,
            blueGradientSecondary2,
          ],
        ),
      ),
      child: Column(
        children: [
          Image.network(
            produk.imageUrl,
            width: 110,
            height: 100,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            produk.name,
            style: bold.copyWith(
              fontSize: 12,
              color: whiteColor,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
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
            width: 108,
            height: 24,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: whiteColor, width: 1),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => produk.navigasi));
              },
              child: Text(
                AppLocalizations.of(context)!.detailProduct,
                style: reguler.copyWith(
                  fontSize: 10,
                  color: whiteColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
