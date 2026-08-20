import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/database/db_materi.dart';
import 'package:blabla/widgets/app_bar.dart';
import 'package:blabla/widgets/app_button.dart';
import 'package:flutter/material.dart';

class Materi1Gelombag extends StatefulWidget {
  const Materi1Gelombag({super.key});

  @override
  State<Materi1Gelombag> createState() => _Materi1State();
}

class _Materi1State extends State<Materi1Gelombag> {
  // Waktu mulai belajar dicatat saat halaman dibuka
  final DateTime _startTime = DateTime.now();

  // Simpan riwayat belajar ke database
  Future<void> _saveMateriHistory() async {
    final durationSeconds = DateTime.now().difference(_startTime).inSeconds;
    await DatabaseHelperMateri.instance.insertHistory(
      materiId: 1,
      materiName: 'Gelombang dan Osilasi',
      durationSeconds: durationSeconds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBarMateri(title: "Gelombang dan Osilasi"),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(
              '1.1 Pengantar Gelombang dan Osilasi',
              style: AppTextStyle.subjudul,
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 15),
            Text(
              '''Kita mulai mempelajari osilasi dengan sistem sederhana pendulum dan pegas. Meskipun sistem ini mungkin terlihat sangat mendasar, konsep yang terlibat memiliki banyak aplikasi dalam kehidupan nyata. Sebagai contoh, Gedung Comcast di Philadelphia, Pennsylvania, berdiri setinggi sekitar 305 meter (1000 kaki). Karena gedung dibangun semakin tinggi, gedung tersebut dapat bertindak sebagai pendulum fisik terbalik, dengan lantai atas berosilasi karena aktivitas seismik dan angin yang berfluktuasi. Di Gedung Comcast, peredam massa tertala digunakan untuk mengurangi osilasi. Dipasang di puncak gedung adalah peredam massa kolom cairan tertala, yang terdiri dari reservoir air berkapasitas 300.000 galon. Tangki berbentuk U ini memungkinkan air berosilasi bebas pada frekuensi yang cocok dengan frekuensi alami gedung. Peredaman disediakan dengan menyetel tingkat turbulensi dalam air yang bergerak menggunakan sekat. ''',
              style: AppTextStyle.normalText2,
              textAlign: TextAlign.justify,
            ),
            // TOMBOL SELESAI DAN LANJUTKAN
            SizedBox(height: 20),
            Row(
              children: [
                // ── Tombol SELESAI ───────────────────────────────────────────────
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // Simpan riwayat belajar sebelum kembali
                      await _saveMateriHistory();
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.check,
                      color: AppTheme.putih,
                      size: 16,
                    ),
                    label: Text(
                      'SELESAI',
                      style: AppTextStyle.botttonText.copyWith(color: AppTheme.putih),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.glassBorder, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // tombol lanjutkan
                Expanded(
                  child: CustomElevatedButton(
                    onPressed: () {},
                    text: 'LANJUTKAN',
                    backgroundColor: AppTheme.progressColor,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}
