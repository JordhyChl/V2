import 'package:flutter/material.dart';
import 'package:gpsid/model/pemasangan.dart';
import 'package:gpsid/theme.dart';

class PemasanganCard extends StatelessWidget {
  final Pemasangan pemasangan;
  const PemasanganCard(this.pemasangan, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      width: double.infinity,
      height: 70,
      child: Row(
        children: [
          Image.asset(
            pemasangan.imageUrl,
            width: 50,
          ),
          const SizedBox(
            width: 17,
          ),
          Text(
            pemasangan.name,
            style: bold.copyWith(
              fontSize: 14,
              color: blackPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
