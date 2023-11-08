import 'package:flutter/material.dart';
import 'package:gpsid/theme.dart';

class BottomDetailBar extends StatelessWidget {
  const BottomDetailBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
        width: 1,
        color: greyColor,
      ))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: 160,
            height: 40,
            child: ElevatedButton(
              // color: whiteColor,
              // disabledColor: blueGradientSecondary2,
              // shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(12),
              //     side: BorderSide(
              //       color: bluePrimary,
              //       width: 1,
              //     )),
              onPressed: () {},
              child: Text(
                'Beli Melalui Whatsapp',
                style: reguler.copyWith(
                  fontSize: 10,
                  color: bluePrimary,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 160,
            height: 40,
            child: ElevatedButton(
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(12),
                // ),
                // color: greenPrimary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    context: context,
                    builder: (context) {
                      return SizedBox(
                        width: 375,
                        height: 250,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Spacer(),
                                  Text(
                                    'Beli Produk',
                                    style: bold.copyWith(
                                      fontSize: 16,
                                      color: blackPrimary,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 92,
                                  ),
                                  InkWell(
                                    onTap: () => Navigator.pop(context),
                                    child: Image.asset(
                                      'assets/close_icon.png',
                                      width: 40,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/tokopedia_icon.png',
                                        width: 32,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        'Tokopedia',
                                        style: reguler.copyWith(
                                          fontSize: 12,
                                          color: blackSecondary1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_forward),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Divider(
                                height: 5,
                                thickness: 1,
                                indent: 40,
                                endIndent: 0,
                                color: greyColor,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/shopee_icon.png',
                                        width: 32,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        'Shopee',
                                        style: reguler.copyWith(
                                          fontSize: 12,
                                          color: blackSecondary1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_forward),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Divider(
                                height: 5,
                                thickness: 1,
                                indent: 40,
                                endIndent: 0,
                                color: greyColor,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/tiktok_icon.png',
                                        width: 32,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        'Tiktok',
                                        style: reguler.copyWith(
                                          fontSize: 12,
                                          color: blackSecondary1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_forward),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Text(
                  'Beli di marketplace',
                  style: reguler.copyWith(
                    fontSize: 10,
                    color: whiteColor,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
