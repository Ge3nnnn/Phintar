import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/providers/lab_provider.dart';
import 'package:blabla/views/5_features/lab_page/lab_simulation_pendulum.dart';
import 'package:blabla/widgets/app_banner.dart';
import 'package:blabla/widgets/app_bar.dart';
import 'package:blabla/widgets/app_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Lab list page — dynamically populated from database via [LabProvider].
///
/// No more hardcoded lab items. Adding a new lab only requires adding
/// a JSON entry in the seed file (or inserting into the database).
class LabPagePhintar extends StatefulWidget {
  const LabPagePhintar({super.key});

  @override
  State<LabPagePhintar> createState() => _LabPagePhintaarState();
}

class _LabPagePhintaarState extends State<LabPagePhintar> {
  String _searchQuery = '';

  /// Builds the lab listing page: watches [LabProvider] for data,
  /// shows a loading spinner, search bar, and dynamically renders
  /// lab cards from the database. To add a new lab, insert a new
  /// entry in the lab seed JSON — no code changes needed.
  @override
  Widget build(BuildContext context) {
    final labProvider = context.watch<LabProvider>();

    // Filter labs based on search query
    final allLabs = labProvider.labList;
    final filteredLabs = _searchQuery.isEmpty
        ? allLabs
        : allLabs
            .where((l) =>
                l.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (l.subtitle ?? '')
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar(title: "Laboratorium"),
      body: labProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.bottonColor),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Daftar Laboratorium", style: AppTextStyle.subjudul),
                    const SizedBox(height: 10),
                    // Search Bar
                    CustomSearchBar(
                      hintText: 'Cari laboratorium...',
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                    const SizedBox(height: 20),
                    // Results or empty state
                    if (filteredLabs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'Belum ada laboratorium tersedia.'
                                : 'Laboratorium "$_searchQuery" tidak ditemukan.',
                            style: AppTextStyle.normalText,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ...filteredLabs.map(
                        (lab) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: EnterCourse(
                            title: lab.title,
                            subtitle: lab.subtitle ?? '',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      LabSimulationScreen(lab: lab),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
