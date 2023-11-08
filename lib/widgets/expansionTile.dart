// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:gpsid/model/expansionTile.dart';
import 'package:gpsid/theme.dart';

class ExpansionTileCustom extends StatelessWidget {
  final ExpTile expTile;

  const ExpansionTileCustom(this.expTile, {super.key});

  @override
  Widget build(BuildContext context) {
    bool opened = expTile.open;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: opened
                  ? const BorderRadius.vertical(top: Radius.circular(12))
                  : BorderRadius.circular(12),
              border: Border.all(
                width: 1.5,
                color: bluePrimary,
              )),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                expTile.title,
                style: bold.copyWith(
                  overflow: TextOverflow.visible,
                  fontSize: 12,
                  color: blackSecondary1,
                ),
              ),
              expTile.open
                  ? const Icon(
                      Icons.expand_less,
                      size: 20,
                    )
                  : const Icon(
                      Icons.expand_more,
                      size: 20,
                    )
            ],
          ),
        ),
        Visibility(
            visible: expTile.open,
            child: Container(
              color: whiteCardColor,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Text(
                expTile.body,
                style: reguler.copyWith(
                  fontSize: 10,
                  color: blackSecondary2,
                ),
              ),
            )),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }
}
