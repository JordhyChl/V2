// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/productdetail.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:skeletons/skeletons.dart';

class ProductDetail extends StatefulWidget {
  final int productID;
  final String productName;
  final bool darkMode;
  const ProductDetail(
      {Key? key,
      required this.productName,
      required this.productID,
      required this.darkMode})
      : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail>
    with TickerProviderStateMixin {
  late Future<dynamic> _getProductDetail;
  late ProductDetailModel initProductDetail;

  @override
  void initState() {
    super.initState();
    _getProductDetail = getProductDetail(widget.productID);
  }

  Future<dynamic> getProductDetail(int id) async {
    final result = await APIService().getProductDetail(id);
    if (result is ErrorTrapModel) {
      setState(() {});
    } else {
      setState(() {});
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 3, vsync: this);
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (() => Navigator.pop(context)),
          child: const Icon(Icons.arrow_back),
        ),
        title: Text(
          widget.productName,
          style: bold.copyWith(
            fontSize: 18,
          ),
        ),
        backgroundColor: widget.darkMode ? whiteCardColor : bluePrimary,
      ),
      body: FutureBuilder(
          future: _getProductDetail,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data is ErrorTrapModel) {
                return Column(
                  children: [
                    SkeletonTheme(
                      themeMode:
                          widget.darkMode ? ThemeMode.dark : ThemeMode.light,
                      child: const SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                            shape: BoxShape.rectangle, width: 375, height: 250),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SkeletonTheme(
                      themeMode:
                          widget.darkMode ? ThemeMode.dark : ThemeMode.light,
                      child: const SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                            shape: BoxShape.rectangle,
                            width: double.infinity,
                            height: 54),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SkeletonTheme(
                      themeMode:
                          widget.darkMode ? ThemeMode.dark : ThemeMode.light,
                      child: const SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                            shape: BoxShape.rectangle,
                            width: double.infinity,
                            height: 195),
                      ),
                    ),
                  ],
                );
              } else {
                initProductDetail = snapshot.data;
                return Column(
                  children: [
                    SizedBox(
                      width: 275,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(initProductDetail.data.picture),
                      ),
                    ),
                    Container(
                      color: widget.darkMode ? whiteCardColor : null,
                      width: double.infinity,
                      height: 54,
                      child: TabBar(
                        isScrollable: true,
                        labelColor: bluePrimary,
                        labelStyle: bold.copyWith(
                          fontSize: 16,
                          color: bluePrimary,
                        ),
                        unselectedLabelColor: greyColor,
                        controller: tabController,
                        tabs: const [
                          SizedBox(
                            height: 54,
                            width: 180,
                            child: Tab(
                              text: 'Deskripsi',
                            ),
                          ),
                          SizedBox(
                            height: 54,
                            width: 180,
                            child: Tab(
                              text: 'Fitur',
                            ),
                          ),
                          SizedBox(
                            height: 54,
                            width: 180,
                            child: Tab(
                              text: 'Pemasangan',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: TabBarView(
                      controller: tabController,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(15),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Html(
                                data: initProductDetail.data.description,
                                style: {
                                  "div": Style(
                                      // backgroundColor: whiteColorDarkMode,
                                      color: blackPrimary),
                                },
                              ),
                            )),
                        ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: initProductDetail.data.features.length,
                            itemBuilder: (context, index) {
                              return SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, bottom: 15),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Image.network(
                                              initProductDetail
                                                  .data.features[index].icon,
                                              width: 50,
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : null,
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                              // width: 250,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    child: Text(
                                                      initProductDetail.data
                                                          .features[index].name,
                                                      style: bold.copyWith(
                                                        fontSize: 14,
                                                        color: blackPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
                                                  Text(
                                                    initProductDetail
                                                        .data
                                                        .features[index]
                                                        .description,
                                                    style: reguler.copyWith(
                                                      fontSize: 11,
                                                      color: widget.darkMode
                                                          ? whiteColorDarkMode
                                                          : blackSecondary2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    )),
                              );
                            }),
                        Padding(
                            padding: const EdgeInsets.all(15),
                            child: SingleChildScrollView(
                              child: Html(
                                data: initProductDetail.data.installation,
                                style: {
                                  "ul": Style(
                                      // backgroundColor: whiteColorDarkMode,
                                      color: blackPrimary),
                                },
                              ),
                            )),
                        // _pemasangan(),
                      ],
                    ))
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.vertical,
                    //   physics:
                    //       const ScrollPhysics(parent: BouncingScrollPhysics()),
                    //   child: Column(
                    //     children: [
                    //       SizedBox(
                    //         width: double.infinity,
                    //         height: 200,
                    //         child: TabBarView(
                    //           controller: tabController,
                    //           children: [
                    //             // _deskripsi(initProductDetail.data.description),
                    //             ListView.builder(
                    //               itemBuilder: (context, index) {
                    //                 return SingleChildScrollView(
                    //                   child: Padding(
                    //                     padding: const EdgeInsets.all(20),
                    //                     child: Text(
                    //                       initProductDetail.data.description,
                    //                       style: reguler.copyWith(
                    //                         fontSize: 15,
                    //                         color: blackSecondary2,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 );
                    //               },
                    //             ),
                    //             ListView.builder(
                    //                 scrollDirection: Axis.vertical,
                    //                 itemCount:
                    //                     initProductDetail.data.features.length,
                    //                 itemBuilder: (context, index) {
                    //                   return _fitur(
                    //                       initProductDetail
                    //                           .data.features[index].icon,
                    //                       initProductDetail
                    //                           .data.features[index].description,
                    //                       initProductDetail
                    //                           .data.features[index].name);
                    //                 }),
                    //             // _fitur(initProductDetail.data.features[index].),
                    //             ListView.builder(
                    //                 scrollDirection: Axis.vertical,
                    //                 itemCount: initProductDetail
                    //                     .data.installation.length,
                    //                 itemBuilder: (context, index) {
                    //                   return _pemasangan(
                    //                       initProductDetail.data.installation,
                    //                       initProductDetail.data.installation);
                    //                 }),
                    //             // _pemasangan(),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // )
                  ],
                );
              }
            }
            return Column(
              children: [
                SkeletonTheme(
                  themeMode: widget.darkMode ? ThemeMode.dark : ThemeMode.light,
                  child: const SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                        shape: BoxShape.rectangle, width: 375, height: 250),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                SkeletonTheme(
                  themeMode: widget.darkMode ? ThemeMode.dark : ThemeMode.light,
                  child: const SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                        shape: BoxShape.rectangle,
                        width: double.infinity,
                        height: 54),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                SkeletonTheme(
                  themeMode: widget.darkMode ? ThemeMode.dark : ThemeMode.light,
                  child: const SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                        shape: BoxShape.rectangle,
                        width: double.infinity,
                        height: 195),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
