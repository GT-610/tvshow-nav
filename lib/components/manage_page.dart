import 'package:fluent_ui/fluent_ui.dart';
import 'package:tvshow_nav/components/empty_state.dart';
import 'package:tvshow_nav/components/link_card.dart';
import 'package:tvshow_nav/controllers/link_controller.dart';
import 'package:tvshow_nav/models/link.dart';

typedef OnAdd = void Function();
typedef OnEdit = void Function(int id);
typedef OnDelete = void Function(int id);

class ManagePage extends StatelessWidget {
  final List<TvLink> links;
  final LinkLoadState loadState;
  final String? errorMessage;
  final OnAdd onAdd;
  final OnEdit onEdit;
  final OnDelete onDelete;
  final VoidCallback onRetry;

  const ManagePage({
    super.key,
    required this.links,
    required this.loadState,
    required this.errorMessage,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommandBar(
            primaryItems: [
              CommandBarButton(
                icon: const Icon(WindowsIcons.add),
                label: const Text('添加节目'),
                onPressed: onAdd,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Expanded(
            child: loadState == LinkLoadState.loading
                ? const Center(child: ProgressRing())
                : loadState == LinkLoadState.error
                    ? EmptyState(
                        icon: WindowsIcons.error,
                        title: '节目列表加载失败',
                        subtitle: errorMessage ?? '请稍后重试。',
                        action: FilledButton(
                          onPressed: onRetry,
                          child: const Text('重新加载'),
                        ),
                      )
                    : links.isEmpty
                        ? EmptyState(
                            icon: WindowsIcons.list,
                            title: '暂无直播链接',
                            action: FilledButton(
                              onPressed: onAdd,
                              child: const Text('添加第一个节目'),
                            ),
                          )
                        : ListView.builder(
                            itemCount: links.length,
                            itemBuilder: (context, index) {
                              final link = links[index];
                              return LinkCard(
                                link: link,
                                onEdit: link.id != null
                                    ? () => onEdit(link.id!)
                                    : null,
                                onDelete: link.id != null
                                    ? () => onDelete(link.id!)
                                    : null,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
