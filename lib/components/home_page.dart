import 'package:fluent_ui/fluent_ui.dart';
import 'package:tvshow_nav/controllers/link_controller.dart';
import 'package:tvshow_nav/models/link.dart';
import 'package:tvshow_nav/components/link_card.dart';
import 'package:tvshow_nav/components/empty_state.dart';

class HomePage extends StatelessWidget {
  final List<TvLink> links;
  final LinkLoadState loadState;
  final String? errorMessage;
  final VoidCallback onRetry;

  const HomePage({
    super.key,
    required this.links,
    required this.loadState,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (loadState == LinkLoadState.loading) {
      return const Center(child: ProgressRing());
    }

    if (loadState == LinkLoadState.error) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: EmptyState(
          icon: WindowsIcons.error,
          title: '节目列表加载失败',
          subtitle: errorMessage ?? '请稍后重试。',
          action: FilledButton(
            onPressed: onRetry,
            child: const Text('重新加载'),
          ),
        ),
      );
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
                  key: ValueKey(link.id ?? '${link.name}:${link.url}'),
                  link: link,
                  onEdit: null,
                  onDelete: null,
                );
              },
            ),
    );
  }
}
