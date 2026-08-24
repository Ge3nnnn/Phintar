import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/data/database/db_helper.dart';
import 'package:blabla/data/models/materi_model.dart';
import 'package:blabla/database/db_helper.dart';
import 'package:blabla/widgets/app_button.dart';
import 'package:blabla/widgets/content_block_renderer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dynamic materi detail screen — the SINGLE template for ALL materi.
///
/// Receives a [MateriModel] via constructor and renders its content blocks
/// dynamically. No hardcoded text, images, or navigation targets.
///
/// Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => MateriDetailScreen(materi: someMateriModel),
/// ));
/// ```
class MateriDetailScreen extends StatefulWidget {
  final MateriModel materi;

  /// Optional: total number of pages in a sequence (for progress bar).
  final int totalPages;

  /// Optional: current page index in a sequence (1-based).
  final int currentPage;

  /// Optional: next materi to navigate to.
  final MateriModel? nextMateri;

  const MateriDetailScreen({
    super.key,
    required this.materi,
    this.totalPages = 1,
    this.currentPage = 1,
    this.nextMateri,
  });

  @override
  State<MateriDetailScreen> createState() => _MateriDetailScreenState();
}

class _MateriDetailScreenState extends State<MateriDetailScreen> {
  final DateTime _startTime = DateTime.now();

  /// Saves learning history to database.
  Future<void> _saveMateriHistory() async {
    final durationSeconds = DateTime.now().difference(_startTime).inSeconds;
    await DBHelper().insertMateriHistory(
      materiId: widget.materi.id,
      materiName: widget.materi.title,
      durationSeconds: durationSeconds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header with Progress ─────────────────────────────
            _buildTopHeader(),

            // ── Scrollable Content ───────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Render all content blocks dynamically
                    ...widget.materi.blocks.map(
                      (block) => ContentBlockRenderer(block: block),
                    ),

                    const SizedBox(height: 24),

                    // ── Navigation Buttons ────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildNavigationButtons(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top header with category title and progress bar.
  Widget _buildTopHeader() {
    final progress = widget.totalPages > 0
        ? widget.currentPage / widget.totalPages
        : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () async {
                  await _saveMateriHistory();
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: AppTheme.putih,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.materi.category,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.putih,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Progress bar
        Stack(
          children: [
            Container(
              height: 2.5,
              width: double.infinity,
              color: AppTheme.backgroundSecondary,
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 2.5,
                decoration: const BoxDecoration(
                  color: AppTheme.progressColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.progressColor,
                      blurRadius: 4,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Bottom navigation buttons: Selesai (finish) and Lanjutkan (continue).
  Widget _buildNavigationButtons() {
    return Row(
      children: [
        // ── SELESAI button ────────────────────────────────────────
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              await _saveMateriHistory();
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.check, color: AppTheme.putih, size: 16),
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

        // ── LANJUTKAN button (only if there's a next materi) ─────
        if (widget.nextMateri != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: CustomElevatedButton(
              onPressed: () async {
                await _saveMateriHistory();
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MateriDetailScreen(
                      materi: widget.nextMateri!,
                      totalPages: widget.totalPages,
                      currentPage: widget.currentPage + 1,
                    ),
                  ),
                );
              },
              text: 'LANJUTKAN',
              backgroundColor: AppTheme.progressColor,
              width: double.infinity,
            ),
          ),
        ],
      ],
    );
  }
}
