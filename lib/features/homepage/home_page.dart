import 'package:blabla/database/db_helper.dart';
import 'package:blabla/models/user_model_colour_palatte.dart';
import 'package:blabla/models/user_model_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePagePhintar extends StatefulWidget {
  const HomePagePhintar({super.key});

  @override
  State<HomePagePhintar> createState() => _HomePagepHINTARState();
}

class _HomePagepHINTARState extends State<HomePagePhintar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phintar", style: TextStyle(color: AppColors.textColor)),
        backgroundColor: AppColors.backgroundPrimary,
      ),

      body: Column(
        children: [
          Expanded(
            // FutureBuilder digunakan untuk mengambil data secara asynchronous dari fungsi DBHelper().getAllUsers()
            child: FutureBuilder<List<UserModelSQL>>(
              future: DBHelper().getAllUsers(),
              builder: (context, snapshot) {
                // Status 1: Sedang memuat data dari database
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Status 2: Terjadi error saat membaca data
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Terjadi kesalahan: ${snapshot.error}'),
                  );
                }

                // Status 3: Data kosong / belum ada pengguna di database
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada data pengguna.'));
                }

                // Status 4: Data berhasil diambil
                final daftarPengguna = snapshot.data!;

                return ListView.builder(
                  itemCount: daftarPengguna.length,
                  itemBuilder: (context, index) {
                    final user = daftarPengguna[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(user.email),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Password: ${user.password}'),
                            Text('Nama: ${user.nama}'),
                          ],
                        ),
                        // trailing: Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //     // Tombol Edit Data Pengguna
                        //     IconButton(
                        //       onPressed: () {
                        //         _showBottomSheet(context, user);
                        //       },
                        //       icon: const Icon(Icons.edit),
                        //     ),
                        //     // Tombol Hapus Data Pengguna
                        //     IconButton(
                        //       onPressed: () {
                        //         _showBottomSheet(context, user);
                        //       },
                        //       icon: const Icon(Icons.delete),
                        //     ),
                        //   ],
                        // ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
