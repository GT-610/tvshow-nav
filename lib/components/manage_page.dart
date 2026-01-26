import 'package:fluent_ui/fluent_ui.dart';
import 'package:tvshow_nav/models/link.dart';
import 'package:tvshow_nav/components/uninitialized_view.dart';
import 'package:tvshow_nav/components/link_card.dart';

typedef OnAdd = void Function();
typedef OnEdit = void Function(int id);
typedef OnDelete = void Function(int id);

class ManagePage extends StatelessWidget {
  final bool dbInitialized;
  final List<TvLink> links;
  final OnAdd onAdd;
  final OnEdit onEdit;
  final OnDelete onDelete;

  const ManagePage({
    super.key,
    required this.dbInitialized,
    required this.links,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (!dbInitialized) {
      return const UninitializedView();
    }

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
            child: links.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          WindowsIcons.list,
                          size: 64,
                          color: Colors.grey[40],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '暂无直播链接',
                          style:
                              FluentTheme.of(context).typography.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: onAdd,
                          child: const Text('添加第一个节目'),
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
                        onEdit: () => onEdit(link.id),
                        onDelete: () => onDelete(link.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
