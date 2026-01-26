import 'package:fluent_ui/fluent_ui.dart';
import 'package:tvshow_nav/models/link.dart';
import 'package:tvshow_nav/components/uninitialized_view.dart';
import 'package:tvshow_nav/components/link_card.dart';

class HomePage extends StatelessWidget {
  final bool dbInitialized;
  final List<TvLink> links;

  const HomePage({
    super.key,
    required this.dbInitialized,
    required this.links,
  });

  @override
  Widget build(BuildContext context) {
    if (!dbInitialized) {
      return const UninitializedView();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: links.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    WindowsIcons.video,
                    size: 64,
                    color: Colors.grey[40],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无直播链接',
                    style: FluentTheme.of(context).typography.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '请切换到管理页面添加直播链接',
                    style: TextStyle(color: Colors.grey[60]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: links.length,
              itemBuilder: (context, index) {
                final link = links[index];
                return LinkCard(
                  link: link,
                  onEdit: null,
                  onDelete: null,
                );
              },
            ),
    );
  }
}
