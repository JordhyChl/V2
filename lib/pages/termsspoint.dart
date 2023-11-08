import 'package:flutter/material.dart';
import 'package:gpsid/theme.dart';

class TermSSPoint extends StatefulWidget {
  const TermSSPoint({Key? key}) : super(key: key);

  @override
  State<TermSSPoint> createState() => _TermSSPointState();
}

class _TermSSPointState extends State<TermSSPoint>
    with TickerProviderStateMixin {
  List<String> title = [
    'Apa itu SSPoin?',
    'Berapa Poin Yang Didapatkan Saat Topup?',
    'Berapa Poin Yang Didapatkan Saat Tambah Unit?',
    'Berapa Poin Yang Didapatkan Saat Trade In?',
    'Berapa Poin Yang Didapatkan Saat Mendaftar Menggunakan Referral?',
  ];
  bool opened = false;
  String lorem =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nec consequat, pellentesque vitae mauris tortor, ipsum bibendum. Non sit sagittis, non nunc. Ultrices montes, ipsum sem elementum curabitur ante arcu. A id tristique justo est faucibus tincidunt augue orci, porttitor.';
  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 2, vsync: this);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bluePrimary,
        title: const Text('SSPoin'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: bluePrimary,
            ),
            width: double.infinity,
            height: 54,
            child: TabBar(
              indicatorColor: whiteColor,
              labelColor: whiteColor,
              labelStyle: bold.copyWith(
                fontSize: 12,
                color: bluePrimary,
              ),
              unselectedLabelStyle:
                  reguler.copyWith(fontSize: 12, color: whiteCardColor),
              unselectedLabelColor: whiteCardColor,
              controller: tabController,
              tabs: const [
                Tab(
                  text: 'FAQ',
                ),
                Tab(
                  text: 'Syarat & Ketentuan',
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 700,
            child: Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  faq(),
                  sandk(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  sandk() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Syarat & Ketentuan',
            style: bold.copyWith(
              fontSize: 12,
              color: blackPrimary,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            '1. LLorem ipsum dolor sit amet, consectetur adipiscing elit. Nec consequat, pellentesque vitae mauris tortor, ipsum bibendum. Non sit sagittis, non nunc. Ultrices montes, ipsum sem elementum curabitur ante arcu. A id tristique justo est faucibus tincidunt augue orci, porttitor.',
            style: reguler.copyWith(
              fontSize: 10,
              color: blackSecondary2,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            '2. LLorem ipsum dolor sit amet, consectetur adipiscing elit.',
            style: reguler.copyWith(
              fontSize: 10,
              color: blackSecondary2,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            '3. LLorem ipsum dolor sit amet, consectetur adipiscing elit. Nec consequat, pellentesque vitae mauris tortor, ipsum bibendum. Non sit sagittis, non nunc. ',
            style: reguler.copyWith(
              fontSize: 10,
              color: blackSecondary2,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            '4. LLorem ipsum dolor sit amet, consectetur adipiscing elit. Nec consequat, pellentesque vitae mauris tortor, ipsum bibendum. Non sit sagittis, non nunc. Ultrices montes, ipsum sem elementum curabitur ante arcu. ',
            style: reguler.copyWith(
              fontSize: 10,
              color: blackSecondary2,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            '5. LLorem ipsum dolor sit amet, consectetur adipiscing elit. Nec consequat, pellentesque vitae mauris tortor, ipsum bibendum. Non sit sagittis, non nunc. Ultrices montes, ipsum sem elementum curabitur ante arcu. A id tristique justo est faucibus tincidunt augue orci, porttitor.',
            style: reguler.copyWith(
              fontSize: 10,
              color: blackSecondary2,
            ),
          ),
        ],
      ),
    );
  }

  faq() {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
            itemCount: title.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    opened = !opened;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: bluePrimary, width: 1),
                  ),
                  margin: const EdgeInsets.all(12),
                  child: ExpansionTile(
                    childrenPadding: const EdgeInsets.all(20),
                    collapsedBackgroundColor: whiteColor,
                    backgroundColor: whiteCardColor,
                    title: Text(
                      title[index],
                      style: bold.copyWith(
                        fontSize: 12,
                        color: blackPrimary,
                      ),
                    ),
                    children: [
                      Text(
                        lorem,
                        style: reguler.copyWith(
                          fontSize: 10,
                          color: blackSecondary2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  // customExpansion() {
  //   return Expansion
  // }
}
