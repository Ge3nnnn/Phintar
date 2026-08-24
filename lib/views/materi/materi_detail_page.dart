import 'package:flutter/material.dart';
import '../../data/models/materi_model.dart';

class MateriDetailPage extends StatelessWidget {
  final MateriModel materi;

  const MateriDetailPage({Key? key, required this.materi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(materi.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image
            if (materi.bannerUrl.isNotEmpty)
              Image.network(
                materi.bannerUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                materi.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            // Content Blocks
            ...materi.blocks.map((block) {
              switch (block.type) {
                case 'text':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(block.content),
                  );
                case 'image':
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.network(block.content),
                  );
                default:
                  return const SizedBox.shrink();
              }
            }).toList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
