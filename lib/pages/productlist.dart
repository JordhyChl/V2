import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/product.model.dart';
import 'package:gpsid/pages/productdetail.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:skeletons/skeletons.dart';

class ProdukList extends StatefulWidget {
  final bool darkMode;
  const ProdukList({Key? key, required this.darkMode}) : super(key: key);

  @override
  State<ProdukList> createState() => _ProductListState();
}

class _ProductListState extends State<ProdukList> {
  late Future<dynamic> _getProduct;
  late List<ResultProduct> products;

  @override
  void initState() {
    super.initState();
    _getProduct = getProduct();
  }

  Future<dynamic> getProduct() async {
    final result = await APIService().getProduct();
    if (result is ErrorTrapModel) {
      setState(() {
        // initPlatformState();
      });
    } else {
      setState(() {});
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: _appBar(context),
      body: _bodyProdukList(),
    );
  }

  _appBar(context) {
    return AppBar(
      leading: GestureDetector(
        onTap: (() => Navigator.pop(context)),
        child: const Icon(Icons.arrow_back),
      ),
      title: Text(
        AppLocalizations.of(context)!.allProduct,
        style: bold.copyWith(
          fontSize: 18,
        ),
      ),
      backgroundColor: widget.darkMode ? whiteCardColor : bluePrimary,
    );
  }

  _bodyProdukList() {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder(
            future: _getProduct,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data is ErrorTrapModel) {
                  return ListView.builder(
                      itemCount: 5,
                      itemBuilder: (BuildContext context, int index) {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                  width: 400,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: SkeletonTheme(
                                    themeMode: widget.darkMode
                                        ? ThemeMode.dark
                                        : ThemeMode.light,
                                    child: const SkeletonAvatar(
                                      style: SkeletonAvatarStyle(
                                          shape: BoxShape.rectangle,
                                          width: 120,
                                          height: 121),
                                    ),
                                  )),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        );
                      });
                } else {
                  products = snapshot.data.data.resultProduct;
                  return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (BuildContext context, int index) {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: whiteCardColor,
                                  // border:
                                  //     Border.all(width: 1.5, color: greyColor),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(8),
                                              topLeft: Radius.circular(8)),
                                          gradient: LinearGradient(
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomLeft,
                                            colors: [
                                              blueGradientSecondary1,
                                              blueGradientSecondary2,
                                            ],
                                          ),
                                        ),
                                        width: 80,
                                        height: 121,
                                        child: Image.network(
                                          products[index].picture,
                                          // width: 50,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            products[index].name,
                                            style: bold.copyWith(
                                              fontSize: 14,
                                              color: blackPrimary,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          // SizedBox(
                                          //   width: 191,
                                          //   child:

                                          //       // Html(
                                          //       //     data: products[index]
                                          //       //         .description)

                                          //       AutoSizeText(
                                          //     products[index].description,
                                          //     style: bold.copyWith(
                                          //       fontSize: 10,
                                          //       color: blackSecondary2,
                                          //     ),
                                          //     minFontSize: 10,
                                          //     maxLines: 2,
                                          //     overflow: TextOverflow.ellipsis,
                                          //   ),
                                          //   // Text(
                                          //   //   products[index].description,
                                          //   //   style: reguler.copyWith(
                                          //   //     fontSize: 10,
                                          //   //     color: blackSecondary2,
                                          //   //   ),
                                          //   // ),
                                          // ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder:
                                                              (context) =>
                                                                  ProductDetail(
                                                                    productName:
                                                                        products[index]
                                                                            .name,
                                                                    productID:
                                                                        products[index]
                                                                            .iD,
                                                                    darkMode: widget
                                                                        .darkMode,
                                                                  )));
                                                },
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
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        );
                      });
                }
              }
              return ListView.builder(
                  itemCount: 5,
                  itemBuilder: (BuildContext context, int index) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                              width: 400,
                              decoration: BoxDecoration(
                                // border:
                                //     Border.all(width: 1.5, color: greyColor),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: SkeletonTheme(
                                themeMode: widget.darkMode
                                    ? ThemeMode.dark
                                    : ThemeMode.light,
                                child: const SkeletonAvatar(
                                  style: SkeletonAvatarStyle(
                                      shape: BoxShape.rectangle,
                                      width: 120,
                                      height: 121),
                                ),
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    );
                  });
            }));
  }
}
