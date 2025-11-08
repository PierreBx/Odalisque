import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// Static content page with text and images.
class FrontPage extends StatelessWidget {
  final PageConfig config;

  const FrontPage({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final content = config.config?['content'] as Map<String, dynamic>?;
    if (content == null) {
      return const Center(child: Text('No content configured'));
    }

    final text = content['text'] as String?;
    final image = content['image'] as String?;
    final alignment = content['alignment'] as String? ?? 'center';

    final crossAlignment = alignment == 'left'
        ? CrossAxisAlignment.start
        : alignment == 'right'
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.center;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: crossAlignment,
        children: [
          if (image != null) ...[
            Image.asset(
              image,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
          ],
          if (text != null)
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: alignment == 'left'
                  ? TextAlign.left
                  : alignment == 'right'
                      ? TextAlign.right
                      : TextAlign.center,
            ),
        ],
      ),
    );
  }
}
