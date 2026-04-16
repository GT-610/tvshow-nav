import 'package:fluent_ui/fluent_ui.dart';
import 'package:tvshow_nav/models/link.dart';
import 'package:tvshow_nav/components/link_card.dart';
import 'package:tvshow_nav/components/empty_state.dart';

class HomePage extends StatelessWidget {
  final List<TvLink> links;
  final bool isLoading;

  const HomePage({
    super.key,
    required this.links,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: ProgressRing());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: links.isEmpty
          ? const EmptyState(
              icon: WindowsIcons.video,
              title: '暂无直播链接',
              subtitle: '请切换到管理页面添加直播链接',
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
