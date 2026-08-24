import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/data/models/materi_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
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
        return _buildFormulaCard(block.content);

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

  /// Styled card for physics formulas.
  Widget _buildFormulaCard(String formula) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryTranslucent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.bottonColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.functions, color: AppTheme.bottonColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Rumus',
                  style: AppTextStyle.smallText.copyWith(
                    color: AppTheme.bottonColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formula,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.putih,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
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
