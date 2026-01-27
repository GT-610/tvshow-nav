import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tvshow_nav/models/link.dart';

class LinkCard extends StatelessWidget {
  final TvLink link;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LinkCard({
    super.key,
    required this.link,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    link.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    link.url,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Tooltip(
              message: '打开链接',
              child: IconButton(
                icon: const Icon(WindowsIcons.open_in_new_window, size: 24),
                onPressed: () async {
                  final uri = Uri.parse(link.url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
            ),
            if (onEdit != null) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: '编辑',
                child: IconButton(
                  icon: const Icon(WindowsIcons.edit, size: 24),
                  onPressed: onEdit,
                ),
              ),
            ],
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: '删除',
                child: IconButton(
                  icon: const Icon(WindowsIcons.delete, size: 24),
                  onPressed: onDelete,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
