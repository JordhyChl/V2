import 'package:flutter/material.dart';
import 'package:gpsid/theme.dart';
import 'package:gpsid/model/fitur.dart';

class FiturCard extends StatelessWidget {
  final Fitur fitur;
  const FiturCard(this.fitur, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 375,
      height: 76,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            fitur.imageUrl,
            width: 50,
          ),
          const SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fitur.title,
                style: bold.copyWith(
                  fontSize: 14,
                  color: blackPrimary,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                fitur.desc,
                style: reguler.copyWith(
                  fontSize: 11,
                  color: blackSecondary2,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
