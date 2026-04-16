import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tvshow_nav/models/link.dart';
import 'package:tvshow_nav/view/dialogs.dart';

class LinkCard extends StatefulWidget {
  final TvLink link;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Future<bool> Function(Uri uri)? launcher;

  const LinkCard({
    super.key,
    required this.link,
    this.onEdit,
    this.onDelete,
    this.launcher,
  });

  @override
  State<LinkCard> createState() => _LinkCardState();
}

class _LinkCardState extends State<LinkCard> {
  Future<bool> _launchUri(Uri uri) {
    if (widget.launcher != null) {
      return widget.launcher!(uri);
    }
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

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
                  final uri = Uri.tryParse(widget.link.url);
                  final isValid = uri != null &&
                      uri.hasScheme &&
                      (uri.scheme == 'http' || uri.scheme == 'https');
                  if (!isValid) {
                    await showAppErrorDialog(
                      context,
                      title: '打开失败',
                      content: '直播链接格式无效，请先在设置里检查这个节目的地址。',
                    );
                    return;
                  }

                  try {
                    final launched = await _launchUri(uri);
                    if (!launched && context.mounted) {
                      await showAppErrorDialog(
                        context,
                        title: '打开失败',
                        content: '系统暂时无法打开这个直播链接，请稍后重试。',
                      );
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    await showAppErrorDialog(
                      context,
                      title: '打开失败',
                      content: '打开链接时出现问题，请稍后重试。\n$e',
                    );
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
