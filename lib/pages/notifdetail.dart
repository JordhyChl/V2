// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:gpsid/theme.dart';

class NotifDetail extends StatefulWidget {
  final String from;
  final String title;
  final String subtitle;
  final String desc;
  final String pic;
  final List<String> snk;
  final bool darkMode;
  const NotifDetail(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.desc,
      required this.pic,
      required this.snk,
      required this.from,
      required this.darkMode})
      : super(key: key);

  @override
  State<NotifDetail> createState() => _NotifDetailState();
}

var size, width, height;
List<String> pricepulse = [
  '30',
  '60',
  '180',
  '360',
];

class _NotifDetailState extends State<NotifDetail> {
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: widget.darkMode ? whiteCardColor : bluePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: widget.from == 'info'
            ? SizedBox(
                width: width,
                height: height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image.asset('assets/notifdetailpic.png'),
                    Image.network(widget.pic),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            widget.subtitle,
                            style: bold.copyWith(
                                color: blackPrimary, fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   'Deskripsi Hadiah',
                              //   style: bold.copyWith(
                              //       color: blackPrimary, fontSize: 16),
                              // ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  widget.desc,
                                  style: reguler.copyWith(
                                      color: blackPrimary, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: widget.snk.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Icon(
                                    Icons.circle,
                                    size: 5,
                                    color: blackSecondary2,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    widget.snk[index],
                                    style: reguler.copyWith(
                                        color: widget.darkMode
                                            ? whiteColorDarkMode
                                            : blackSecondary2,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ))
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image.asset('assets/notifdetailpic.png'),
                  Image.network(widget.pic),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          widget.title,
                          style:
                              bold.copyWith(color: blackPrimary, fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.subtitle,
                              style: bold.copyWith(
                                  color: blackPrimary, fontSize: 16),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                widget.desc,
                                style: reguler.copyWith(
                                    color: blackPrimary, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Syarat dan ketentuan',
                              style: bold.copyWith(
                                  color: blackPrimary, fontSize: 16),
                            ),
                            SizedBox(
                              height: 100,
                              width: 250,
                              child: ListView.builder(
                                itemCount: widget.snk.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5),
                                          child: Icon(
                                            Icons.circle,
                                            size: 5,
                                            color: blackPrimary,
                                          ),
                                        ),
                                        Text(
                                          widget.snk[index],
                                          style: reguler.copyWith(
                                              color: blackPrimary,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
      ),
    );
  }
}
