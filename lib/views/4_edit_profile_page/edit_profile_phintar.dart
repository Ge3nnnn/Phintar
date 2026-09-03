import 'dart:io';
import 'package:blabla/widgets/app_button.dart';
import 'package:blabla/widgets/app_textfield.dart';
import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/widgets/app_bar.dart';
import 'package:blabla/data/database/db_helper.dart';
import 'package:blabla/widgets/extention/navigator.dart';
import 'package:blabla/models/preference_handler.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePhintar extends StatefulWidget {
  const EditProfilePhintar({super.key});

  @override
  State<EditProfilePhintar> createState() => _EditProfilePhintarState();
}

class _EditProfilePhintarState extends State<EditProfilePhintar> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isLoading = false;
  File? _imageFile;
  bool _isPhotoDeleted = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: PreferenceHandler.userName);
    _emailController = TextEditingController(text: PreferenceHandler.userEmail);

    final savedPhotoPath = PreferenceHandler.userPhoto;
    if (savedPhotoPath != null && savedPhotoPath.isNotEmpty) {
      final file = File(savedPhotoPath);
      if (file.existsSync()) {
        _imageFile = file;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop();
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isPhotoDeleted = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih foto: $e'),
          backgroundColor: AppTheme.merah,
        ),
      );
    }
  }

  void _removePhoto() {
    Navigator.of(context).pop();
    setState(() {
      _imageFile = null;
      _isPhotoDeleted = true;
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final hasImage =
            _imageFile != null ||
            (!_isPhotoDeleted &&
                (PreferenceHandler.userPhoto?.isNotEmpty ?? false));

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.textColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text("Foto Profil", style: AppTextStyle.subsubjudul),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_rounded,
                    color: AppTheme.bottonColor,
                  ),
                  title: Text(
                    "Pilih dari Galeri",
                    style: AppTextStyle.progresText,
                  ),
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppTheme.bottonColor,
                  ),
                  title: Text(
                    "Ambil Foto (Kamera)",
                    style: AppTextStyle.progresText,
                  ),
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                if (hasImage)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppTheme.merah,
                    ),
                    title: Text("Hapus Foto", style: AppTextStyle.warningText),
                    onTap: _removePhoto,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final newName = _nameController.text.trim();
    final currentEmail = PreferenceHandler.userEmail;

    // Simpan ke SharedPreferences
    await PreferenceHandler.setUserName(newName);

    // Simpan atau hapus path foto profil
    if (_imageFile != null) {
      await PreferenceHandler.setUserPhoto(_imageFile!.path);
    } else if (_isPhotoDeleted) {
      await PreferenceHandler.setUserPhoto(null);
    }

    // Update di database jika email terdaftar
    if (currentEmail.isNotEmpty) {
      final db = await DBHelper().database;
      await db.update(
        'users',
        {'nama': newName},
        where: 'email = ?',
        whereArgs: [currentEmail],
      );
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar2(
        title: "Edit Profile",
        prefixIcon: Icons.arrow_back,
        onPrefixIconTap: () {
          context.pop();
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar preview
                Center(
                  child: GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppTheme.bottonColor.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.bottonColor,
                              width: 2.5,
                            ),
                          ),
                          child: ClipOval(
                            child: _imageFile != null
                                ? Image.file(
                                    _imageFile!,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    color: AppTheme.bottonColor,
                                    size: 52,
                                  ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.bottonColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Input
                    Text("Nama Lengkap", style: AppTextStyle.normalText2Bold),
                    SizedBox(height: 8),
                    CustomTextFields(
                      controller: _nameController,
                      hintText: "Masukkan nama kamu",
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Nama tidak boleh kosong";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Email (Tidak dapat diubah)",
                      style: AppTextStyle.normalTextBold,
                    ),
                    SizedBox(height: 8),
                    // Email Info (Read Only)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.glassBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.glassBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            color: AppTheme.textColor,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _emailController.text.isNotEmpty
                                  ? _emailController.text
                                  : "Belum ada email",
                              style: const TextStyle(
                                color: AppTheme.textColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                // Simpan Button
                CustomElevatedButton(
                  onPressed: _isLoading ? () {} : _saveProfile,
                  backgroundColor: AppTheme.hijau,
                  width: double.infinity,
                  text: "Simpan Perubahan",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
