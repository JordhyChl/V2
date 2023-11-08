// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:gpsid/model/fitur.dart';
import 'package:gpsid/model/pemasangan.dart';
import 'package:gpsid/theme.dart';
import 'package:gpsid/widgets/bottom_detail_bar.dart';
import 'package:gpsid/widgets/fiturcard.dart';
import 'package:gpsid/widgets/pemasangancard.dart';

class S250Page extends StatefulWidget {
  const S250Page({Key? key}) : super(key: key);

  @override
  State<S250Page> createState() => _S250PageState();
}

class _S250PageState extends State<S250Page> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 3, vsync: this);
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: _appBar(context),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 320,
            child: TabBarView(
              controller: tabController,
              children: [
                Image.asset('assets/detail5.png'),
                Image.asset('assets/s250detail.png'),
                Image.asset('assets/detail5.png'),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
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
            width: double.infinity,
            height: 369,
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
      'M20 (PORTABLE)',
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
      'Superspring S-250 adalah alat pelacak kendaraan (vehicle tracker) yang berukuran praktis dengan pemasangan yang tersembunyi sehingga tidak terlihat oleh orang lain. Alat ini memiliki tingkat akurasi yang sangat tinggi, didukung dengan sinyal GSM dan GPS yang sangat stabil sehinggu data perjalanan kendaraan anda bisa terlihat secara rinci.',
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
              imageUrl: 'assets/call.png',
              title: 'Dengar percakapan dalam kabin',
              desc: 'Anda dapat mendengarkan percakapan dalam kabin',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          FiturCard(
            Fitur(
              imageUrl: 'assets/speed.png',
              title: 'Speed buzzer',
              desc: 'GPS dapat didukung perangkat sensor kecepatan',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          FiturCard(
            Fitur(
              imageUrl: 'assets/suhu.png',
              title: 'Sensor suhu',
              desc: 'GPS dapat didukung perangkat pengukur suhu',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          FiturCard(
            Fitur(
              imageUrl: 'assets/pintu.png',
              title: 'Sensor pintu',
              desc: 'GSP dapat didukung perangkat sensor pintu',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          FiturCard(
            Fitur(
              imageUrl: 'assets/komunikasi.png',
              title: 'Komunikasi 2 arah',
              desc: 'GPS dapat didukung perangkat pengukur suhu',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          FiturCard(
            Fitur(
              imageUrl: 'assets/sos.png',
              title: 'SOS panic button',
              desc: 'Panggilan SOS sekali klik melalui GPS anda',
            ),
          ),
          const SizedBox(
            height: 20,
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
