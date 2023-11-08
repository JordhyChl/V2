// ignore_for_file: deprecated_member_use, prefer_typing_uninitialized_variables, avoid_print

import 'package:flutter/material.dart';
import 'package:gpsid/theme.dart';
import 'package:share/share.dart';

class ShareLocationModal extends StatefulWidget {
  const ShareLocationModal({super.key});

  @override
  State<ShareLocationModal> createState() => _ShareLocationModalState();
}

class _ShareLocationModalState extends State<ShareLocationModal> {
  var width, size, height;
  bool isDisabled = false;
  TextEditingController textController = TextEditingController();
  List<String> durationTime = [
    '1 Menit',
    '5 Menit',
    '10 Menit',
    '30 Menit',
    '1 Jam',
  ];
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;

    return SizedBox(
      width: width,
      height: height / 2.3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.close,
                size: 40,
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(
                  20,
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/mobil_bergerak.png',
                      width: 120,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Bagikan Lokasi',
                      style: bold.copyWith(
                        fontSize: 12,
                        color: blackPrimary,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Bagikan lokasi kendaraan anda dengan cepat, mudah, dan tepat.',
                      style: reguler.copyWith(
                        fontSize: 10,
                        color: blackSecondary3,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Durasi',
                        style: bold.copyWith(
                          fontSize: 10,
                          color: blackPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      width: width,
                      height: 40,
                      child: TextField(
                        onSubmitted: (value) {
                          print(value);
                        },
                        style: reguler.copyWith(
                          fontSize: 10,
                          color: blackPrimary,
                        ),
                        readOnly: true,
                        onTap: () => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return dialogShareLocate(context);
                            }),
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              isDisabled = false;
                            });
                          } else if (value == durationTime[selected]) {
                            setState(() {
                              isDisabled = true;
                            });
                          }
                          print(value);
                        },
                        controller: textController,
                        decoration: InputDecoration(
                          fillColor: whiteCardColor,
                          filled: true,
                          hintText: 'Pilih Durasi',
                          hintStyle: reguler.copyWith(
                            fontSize: 10,
                            color: blackSecondary3,
                          ),
                          suffixIcon: const Icon(
                            Icons.arrow_drop_down,
                            size: 20,
                          ),
                          contentPadding: const EdgeInsets.only(
                            top: 5,
                            left: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    border: Border(
                  top: BorderSide(
                    width: 1,
                    color: greyColor,
                  ),
                )),
                alignment: Alignment.center,
                width: double.infinity,
                height: 79,
                child: SizedBox(
                    width: double.infinity,
                    height: 39,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: bluePrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          onPrimary: greyColor),
                      // color: bluePrimary,
                      // disabledColor: greyColor,
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(
                      //     12,
                      //   ),
                      // ),
                      onPressed: isDisabled
                          ? () {
                              Share.share('Test');
                            }
                          : null,
                      child: Text(
                        'Bagikan Lokasi',
                        style: bold.copyWith(
                          fontSize: 16,
                          color: whiteColor,
                        ),
                      ),
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }

  dialogShareLocate(context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 345,
        height: height / 2.4,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pilih Durasi',
                  style: bold.copyWith(
                    fontSize: 16,
                    color: blackPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    size: 40,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
                width: double.infinity,
                height: 180,
                child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return ListView(
                    children: [
                      durationOption(
                        '1 Menit',
                        0,
                        setState,
                      ),
                      durationOption(
                        '5 Menit',
                        1,
                        setState,
                      ),
                      durationOption(
                        '10 Menit',
                        2,
                        setState,
                      ),
                      durationOption(
                        '30 Menit',
                        3,
                        setState,
                      ),
                      durationOption(
                        '1 Jam',
                        4,
                        setState,
                      ),
                    ],
                  );
                })),
            const SizedBox(
              height: 36,
            ),
            Divider(
              height: 1,
              thickness: .5,
              indent: 0,
              endIndent: 0,
              color: greyColor,
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: bluePrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(12),
                // ),
                // color: bluePrimary,
                onPressed: () {
                  setState(() {
                    textController.text = durationTime[selected];
                  });
                  Navigator.pop(context);
                  print(textController.text);
                },
                child: Text(
                  'Simpan',
                  style: bold.copyWith(
                    fontSize: 16,
                    color: whiteColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  durationOption(String time, int index, StateSetter setState) {
    return Column(
      children: [
        Divider(
          height: .5,
          thickness: .5,
          indent: 0,
          endIndent: 0,
          color: selected == index ? bluePrimary : greyColor,
        ),
        const SizedBox(
          height: 8,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              selected = index;
            });
          },
          child: Text(
            time,
            style: selected == index
                ? bold.copyWith(
                    fontSize: 12,
                    color: blackPrimary,
                  )
                : reguler.copyWith(
                    fontSize: 12,
                    color: blackSecondary2,
                  ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }
}
