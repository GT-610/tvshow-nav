import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tvshow_nav/models/link.dart';

class LinkCard extends StatefulWidget {
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
  State<LinkCard> createState() => _LinkCardState();
}

class _LinkCardState extends State<LinkCard> {
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
                    widget.link.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.link.url,
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
                  final uri = Uri.parse(widget.link.url);
                  try {
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      if (mounted) {
                        await showDialog(
                          // ignore: use_build_context_synchronously
                          context: context,
                          builder: (context) => ContentDialog(
                            actions: <Widget>[
                              Button(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('确定'),
                              ),
                            ],
                            content: const Text('无法打开链接'),
                            title: const Text('打开失败'),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      await showDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (context) => ContentDialog(
                          actions: <Widget>[
                            Button(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('确定'),
                            ),
                          ],
                          content: Text('打开链接时出错: $e'),
                          title: const Text('错误'),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            if (widget.onEdit != null) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: '编辑',
                child: IconButton(
                  icon: const Icon(WindowsIcons.edit, size: 24),
                  onPressed: widget.onEdit,
                ),
              ),
            ],
            if (widget.onDelete != null) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: '删除',
                child: IconButton(
                  icon: const Icon(WindowsIcons.delete, size: 24),
                  onPressed: widget.onDelete,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
