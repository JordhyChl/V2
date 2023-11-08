// ignore_for_file: prefer_typing_uninitialized_variables, file_names

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/theme.dart';

class AddToCart extends StatefulWidget {
  const AddToCart({Key? key}) : super(key: key);

  @override
  State<AddToCart> createState() => _AddToCartState();
}

class _AddToCartState extends State<AddToCart> {
  var size, height, width;
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SizedBox(
                    width: double.infinity,
                    height: 425,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 52,
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              width: width / 2,
                              height: 51,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: greyColor, width: 1),
                                  bottom:
                                      BorderSide(color: greyColor, width: 2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.packageEnds,
                                    style: reguler.copyWith(
                                      fontSize: 10,
                                      color: blackSecondary1,
                                    ),
                                  ),
                                  Text(
                                    '12 Desember 2022',
                                    style: bold.copyWith(
                                      fontSize: 16,
                                      color: blackPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              width: width / 2,
                              height: 51,
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: greyColor, width: 1),
                                  bottom:
                                      BorderSide(color: greyColor, width: 2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '08123456789',
                                    style: reguler.copyWith(
                                      fontSize: 10,
                                      color: blackSecondary1,
                                    ),
                                  ),
                                  Text(
                                    'B 1234 GHJ',
                                    style: bold.copyWith(
                                      fontSize: 16,
                                      color: blackPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              pricePackage(0, '365+30', '600', setState),
                              pricePackage(1, '180', '300', setState),
                              pricePackage(2, '30', '65', setState),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                          width: double.infinity,
                          height: 70,
                          decoration: BoxDecoration(
                            color: whiteColor,
                            boxShadow: [
                              BoxShadow(
                                color: greyColor.withOpacity(0.5),
                                blurRadius: 5,
                                spreadRadius: 5,
                                offset: const Offset(
                                  0,
                                  -2,
                                ),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.nextPackage,
                                    style: reguler.copyWith(
                                      fontSize: 10,
                                      color: blackSecondary2,
                                    ),
                                  ),
                                  Text(
                                    '12 Januari 2024',
                                    style: bold.copyWith(
                                      fontSize: 16,
                                      color: blackPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 160,
                                height: 40,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: greenPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    // color: greenPrimary,
                                    // shape: RoundedRectangleBorder(
                                    //   borderRadius: BorderRadius.circular(10),
                                    // ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                bottom: 36,
                                                right: 18,
                                                left: 14,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              title: Stack(
                                                alignment: Alignment.topCenter,
                                                children: [
                                                  Image.asset(
                                                    'assets/cart.png',
                                                    width: 150,
                                                  ),
                                                  Positioned(
                                                    right: 0,
                                                    child: InkWell(
                                                      onTap: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: Icon(
                                                        Icons.close_rounded,
                                                        size: 34,
                                                        color: blackPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              content: Text(
                                                'Tambahan paket berhasil\n dimasukan ke keranjang',
                                                style: reguler.copyWith(
                                                  fontSize: 12,
                                                  color: blackSecondary1,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.add,
                                          size: 16,
                                          color: whiteColor,
                                        ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          'Keranjang Topup',
                                          style: bold.copyWith(
                                            fontSize: 12,
                                            color: whiteColor,
                                          ),
                                        ),
                                      ],
                                    )),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        child: SizedBox(
          height: 25,
          width: 90,
          child: Card(
            color: greenPrimary,
            elevation: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  child: AutoSizeText(
                    '360 + 30 Hari',
                    style: reguler.copyWith(fontSize: 12, color: whiteColor),
                    minFontSize: 6,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                Icon(
                  Icons.keyboard_arrow_down_outlined,
                  size: 12,
                  color: whiteColor,
                )
              ],
            ),
          ),
        ));
  }

  Container pricePackage(
    int index,
    String date,
    String price,
    StateSetter setState,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 19,
      ),
      width: width,
      height: 63,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: greyColor, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    selected = index;
                  });
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      width: 1,
                      color: selected == index ? bluePrimary : blackPrimary,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: selected == index ? bluePrimary : null,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Text(
                '$date ${AppLocalizations.of(context)!.day}',
                style: bold.copyWith(
                  fontSize: 12,
                  color: selected == index ? bluePrimary : blackPrimary,
                ),
              ),
            ],
          ),
          Text(
            'Rp.$price.000',
            style: bold.copyWith(
              fontSize: 12,
              color: selected == index ? bluePrimary : blackPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
