import 'package:blabla/database/db_helper.dart';
import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/models/user_model_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePagePhintar extends StatefulWidget {
  const HomePagePhintar({super.key});

  @override
  State<HomePagePhintar> createState() => _HomePagePhintarState();
}

class _HomePagePhintarState extends State<HomePagePhintar> {
  // Fungsi helper untuk merefresh tampilan ListView ketika data pengguna ditambah/diubah/dihapus.
  void _refreshList() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phintar", style: TextStyle(color: AppTheme.textColor)),
        backgroundColor: AppTheme.backgroundPrimary,
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tombol Edit Data Pengguna
                            IconButton(
                              onPressed: () {
                                _showBottomSheet(context, user);
                              },
                              icon: const Icon(Icons.more_vert),
                            ),
                          ],
                        ),
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

  void _showBottomSheet(BuildContext context, UserModelSQL? user) {
    // Inisialisasi controller teks dari data pengguna yang dipilih (jika ada).
    final emailController = TextEditingController(text: user?.email ?? "");
    final passwordController = TextEditingController(
      text: user?.password ?? "",
    );
    final namaController = TextEditingController(text: user?.nama ?? "");
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsetsGeometry.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Kelola Pengguna',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Input Email
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              // Input Password
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              // Input Nomor HP
              TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Aksi 1: Tambah Pengguna Baru
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Tambah',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  final newUser = UserModelSQL(
                    email: emailController.text.trim(),
                    password: passwordController.text,
                    nama: namaController.text,
                  );

                  bool success = await DBHelper().registerUser(newUser);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    _refreshList();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data berhasil ditambahkan'),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              // Baris Aksi 2 & 3: Update dan Delete Data Pengguna
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Aksi 2: Update Pengguna
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      'Update',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (user?.id != null) {
                        final updatedUser = UserModelSQL(
                          id: user?.id,
                          email: emailController.text.trim(),
                          password: passwordController.text,
                          nama: namaController.text,
                        );

                        bool success = await DBHelper().updateUser(updatedUser);
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          _refreshList();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data berhasil diperbarui'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  // Aksi 3: Delete Pengguna
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (user?.id != null) {
                        await DBHelper().deleteUser(user!.id!);
                        if (context.mounted) {
                          Navigator.pop(context);
                          _refreshList();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data berhasil dihapus'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
