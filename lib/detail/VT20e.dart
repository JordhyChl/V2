// ignore_for_file: file_names, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:gpsid/model/fitur.dart';
import 'package:gpsid/model/pemasangan.dart';
import 'package:gpsid/theme.dart';
import 'package:gpsid/widgets/bottom_detail_bar.dart';
import 'package:gpsid/widgets/fiturcard.dart';
import 'package:gpsid/widgets/pemasangancard.dart';

class VT20ePage extends StatefulWidget {
  const VT20ePage({super.key});

  @override
  State<VT20ePage> createState() => _VT20ePageState();
}

class _VT20ePageState extends State<VT20ePage> with TickerProviderStateMixin {
  var height, size, width;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    TabController tabController = TabController(length: 3, vsync: this);
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: _appBar(context),
      body: Column(
        children: [
          SizedBox(
            width: width,
            height: 320,
            child: TabBarView(
              controller: tabController,
              children: [
                Image.asset('assets/detail3.png'),
                Image.asset('assets/vt20edetail.png'),
                Image.asset('assets/detail3.png'),
              ],
            ),
          ),
          SizedBox(
            width: width,
            height: 54,
            child: TabBar(
              labelColor: bluePrimary,
              labelStyle: bold.copyWith(
                fontSize: 16,
                color: bluePrimary,
              ),
              unselectedLabelColor: greyColor,
              controller: tabController,
              tabs: const [
                Tab(
                  text: 'Deskripsi',
                ),
                Tab(
                  text: 'Fitur',
                ),
                Tab(
                  text: 'Pemasangan',
                ),
              ],
            ),
          ),
          SizedBox(
            width: width,
            height: 368,
            child: TabBarView(
              controller: tabController,
              children: [
                _deskripsi(),
                _fitur(),
                _pemasangan(),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: const BottomDetailBar(),
    );
  }
}

_appBar(context) {
  return AppBar(
    leading: GestureDetector(
      onTap: (() => Navigator.pop(context)),
      child: const Icon(Icons.arrow_back),
    ),
    title: Text(
      'VT20e',
      style: bold.copyWith(
        fontSize: 18,
      ),
    ),
    backgroundColor: bluePrimary,
  );
}

// Deskripsi Tabs
_deskripsi() {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Text(
      'Supersring VT-20 adalah alat pelacak kendaraan/vehicle tracker yang berukur praktis dengan pemasangan yang tersembunyi sehingga tidak terlihat orang lain. Alat ini memiliki tingkat akurasi yang sangan tinggi, didukung dengan GSM dan GPS yang sangat stabil sehingga data perjalanan kendaraan anda bisa terlihat secara rinci.',
      style: reguler.copyWith(
        fontSize: 15,
        color: blackSecondary2,
      ),
    ),
  );
}

// Fitur Tabs
_fitur() {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 18,
      ),
      child: Column(
        children: [
          FiturCard(
            Fitur(
              imageUrl: 'assets/map.png',
              title: 'Lacak posisi kendaraan',
              desc:
                  'Lacak posisi kendaraan anda secara langung melalui\naplikasi GPS ID',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          FiturCard(
            Fitur(
              imageUrl: 'assets/mesin.png',
              title: 'Matikan mesin jarak jauh',
              desc:
                  'Matikan mesin kendaraan ketika hal yang tidak\ndiinginkan terjadi melalu GPS ID',
            ),
          ),
        ],
      ),
    ),
  );
}

//Pemasangan Tabs
_pemasangan() {
  return Column(
    children: [
      PemasanganCard(
        Pemasangan(
          imageUrl: 'assets/mobil.png',
          name: 'Kendaraan roda empat',
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      Divider(
        height: 5,
        thickness: 1,
        indent: 24,
        endIndent: 24,
        color: whiteCardColor,
      ),
      const SizedBox(
        height: 10,
      ),
      PemasanganCard(
        Pemasangan(
          imageUrl: 'assets/motor.png',
          name: 'Sepeda motor',
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      Divider(
        height: 5,
        thickness: 1,
        indent: 24,
        endIndent: 24,
        color: whiteCardColor,
      ),
      const SizedBox(
        height: 10,
      ),
      PemasanganCard(
        Pemasangan(
          imageUrl: 'assets/bis.png',
          name: 'Truk/Bus',
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      Divider(
        height: 5,
        thickness: 1,
        indent: 24,
        endIndent: 24,
        color: whiteCardColor,
      ),
      const SizedBox(
        height: 10,
      ),
      PemasanganCard(
        Pemasangan(
          imageUrl: 'assets/truk.png',
          name: 'Container dan kendaraan lainnya',
        ),
      ),
    ],
  );
}
