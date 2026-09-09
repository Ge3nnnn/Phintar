import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:phintar/constants/app_theme.dart';
import 'package:phintar/constants/app_typografy.dart';
import 'package:phintar/models/materi_model.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Reusable widget that renders a single [ContentBlock] based on its type.
///
/// Supports: text, subtitle, image, formula, lottie, youtube, divider.
/// New types can be added here without modifying any screen files.
class ContentBlockRenderer extends StatelessWidget {
  final ContentBlock block;

  const ContentBlockRenderer({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: _buildBlock(context),
    );
  }

  Widget _buildBlock(BuildContext context) {
    switch (block.type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            block.content,
            style: AppTextStyle.normalText2,
            textAlign: TextAlign.justify,
          ),
        );

      case 'subtitle':
        return Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
          child: Text(
            block.content,
            style: AppTextStyle.subjudul,
            textAlign: TextAlign.left,
          ),
        );

      case 'image':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImage(block.content),
          ),
        );

      case 'formula':
        return _buildFormulaCard(context, block.content);

      case 'lottie':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: Lottie.asset(
              block.content,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  _buildErrorPlaceholder('Animasi tidak ditemukan'),
            ),
          ),
        );

      case 'youtube':
        return _buildYoutubePlayer(block.content);

      case 'divider':
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Divider(color: AppTheme.textColor, height: 1),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  /// Builds an image widget, supporting both asset and network URLs.
  Widget _buildImage(String src) {
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return Image.network(
        src,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            _buildErrorPlaceholder('Gambar tidak dapat dimuat'),
      );
    }
    return Image.asset(
      src,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          _buildErrorPlaceholder('Gambar tidak ditemukan'),
    );
  }

  /// Formats raw math / LaTeX strings into clear, human-readable physics notation.
  static String formatFormula(String raw) {
    String f = raw;

    // Normalisasi newline
    f = f.replaceAll(r'\n', '\n');
    f = f.replaceAll(r'\\', '\n');

    // LaTeX tokens ke simbol Unicode
    f = f.replaceAll(r'\cdot', ' · ');
    f = f.replaceAll(r'\times', ' × ');
    f = f.replaceAll(r'\Sigma', 'Σ');
    f = f.replaceAll(r'\theta', 'θ');
    f = f.replaceAll(r'\pi', 'π');
    f = f.replaceAll(r'\Delta', 'Δ');
    f = f.replaceAll(r'\mu', 'μ');
    f = f.replaceAll(r'\lambda', 'λ');
    f = f.replaceAll(r'\omega', 'ω');
    f = f.replaceAll(r'\alpha', 'α');
    f = f.replaceAll(r'\beta', 'β');
    f = f.replaceAll(r'\quad', '   ');
    f = f.replaceAll(r'\qquad', '     ');

    // RegEx \text{...} -> ...
    f = f.replaceAllMapped(RegExp(r'\\text\{([^}]+)\}'), (m) => m[1] ?? '');

    // RegEx \vec{...} -> ...
    f = f.replaceAllMapped(RegExp(r'\\vec\{([^}]+)\}'), (m) => m[1] ?? '');
    f = f.replaceAll(r'\vec', '');

    // RegEx \sqrt{\frac{a}{b}} -> √(a / b)
    f = f.replaceAllMapped(
      RegExp(r'\\sqrt\{\\frac\{([^}]+)\}\{([^}]+)\}\}'),
      (m) => '√(${m[1]} / ${m[2]})',
    );

    // RegEx \sqrt{a} -> √(a)
    f = f.replaceAllMapped(RegExp(r'\\sqrt\{([^}]+)\}'), (m) => '√(${m[1]})');
    f = f.replaceAll(r'\sqrt', '√');

    // Pecahan umum
    f = f.replaceAll(r'\frac{1}{2}', '½');
    f = f.replaceAll(r'\frac{1}{4}', '¼');
    f = f.replaceAll(r'\frac{3}{4}', '¾');

    // Pecahan generic \frac{a}{b} -> (a / b)
    f = f.replaceAllMapped(
      RegExp(r'\\frac\{([^}]+)\}\{([^}]+)\}'),
      (m) => '(${m[1]} / ${m[2]})',
    );

    // Subscripts
    f = f.replaceAll('_0', '₀');
    f = f.replaceAll('_1', '₁');
    f = f.replaceAll('_2', '₂');
    f = f.replaceAll('_t', 'ₜ');
    f = f.replaceAll('_k', 'ₖ');
    f = f.replaceAll('_s', 'ₛ');
    f = f.replaceAll('_p', 'ₚ');
    f = f.replaceAll('_m', 'ₘ');
    f = f.replaceAll('_x', 'ₓ');
    f = f.replaceAll('_y', 'ᵧ');
    f = f.replaceAll('_{max}', ' (maks)');
    f = f.replaceAll('_{maks}', ' (maks)');

    // Superscripts
    f = f.replaceAll('^2', '²');
    f = f.replaceAll('^3', '³');
    f = f.replaceAll('^-1', '⁻¹');
    f = f.replaceAll('^-2', '⁻²');

    return f.trim();
  }

  /// Styled card for physics formulas with clean math typography and copy action.
  Widget _buildFormulaCard(BuildContext context, String rawFormula) {
    final cleanedFormula = formatFormula(rawFormula);
    final lines = cleanedFormula
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.backgroundSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.bottonColor.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header Bar ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppTheme.primaryTranslucent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.bottonColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.functions_rounded,
                      color: AppTheme.bottonColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rumus Fisika',
                    style: AppTextStyle.smallText.copyWith(
                      color: AppTheme.bottonColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: cleanedFormula));
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: const [
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.putih,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text('Rumus disalin ke clipboard!'),
                            ],
                          ),
                          backgroundColor: AppTheme.progressColor,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.copy_rounded,
                            color: AppTheme.textColor,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Salin',
                            style: AppTextStyle.smallText.copyWith(
                              color: AppTheme.textColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Formula Content Lines ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                children: lines.map((line) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundPrimary.withValues(
                          alpha: 0.7,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.borderColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: SelectableText(
                        line,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.putih,
                          letterSpacing: 0.3,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Real YouTube video embed player using youtube_player_iframe.
  Widget _buildYoutubePlayer(String videoId) {
    return _YoutubeBlockRenderer(videoId: videoId);
  }

  /// Error placeholder when content fails to load.
  Widget _buildErrorPlaceholder(String message) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.broken_image_outlined,
              color: AppTheme.textColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(message, style: AppTextStyle.smallText),
          ],
        ),
      ),
    );
  }
}

/// Stateful widget to manage the YoutubePlayerController lifecycle.
class _YoutubeBlockRenderer extends StatefulWidget {
  final String videoId;

  const _YoutubeBlockRenderer({required this.videoId});

  @override
  State<_YoutubeBlockRenderer> createState() => _YoutubeBlockRendererState();
}

class _YoutubeBlockRendererState extends State<_YoutubeBlockRenderer> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final resolvedVideoId =
        YoutubePlayerController.convertUrlToId(widget.videoId) ??
        widget.videoId;

    _controller = YoutubePlayerController.fromVideoId(
      videoId: resolvedVideoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        loop: false,
        showVideoAnnotations: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.backgroundSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
      ),
    );
  }
}
