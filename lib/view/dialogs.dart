import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:tvshow_nav/components/link_form.dart';
import 'package:tvshow_nav/controllers/link_controller.dart';
import 'package:tvshow_nav/controllers/link_form_controller.dart';

Future<void> showLinkEditorDialog(
  BuildContext context, {
  int? editingId,
}) async {
  final linkController = context.read<LinkController>();
  final formController = context.read<LinkFormController>();

  if (editingId == null) {
    formController.startCreate();
  } else {
    final link =
        linkController.links.firstWhere((item) => item.id == editingId);
    formController.startEdit(link);
  }

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return ContentDialog(
        title: Text(editingId == null ? '添加新节目' : '编辑节目'),
        content: LinkForm(key: ValueKey(editingId ?? 'new')),
        actions: [
          FilledButton(
            onPressed: () => _submitLink(dialogContext),
            child: Text(editingId == null ? '添加' : '更新'),
          ),
          Button(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
        ],
      );
    },
  );
}

Future<void> showDeleteDialog(BuildContext context, int id) async {
  final linkController = context.read<LinkController>();
  final link = linkController.links.firstWhere((item) => item.id == id);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return ContentDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除节目 ${link.name} 吗？此操作不可恢复。'),
        actions: [
          FilledButton(
            style: const ButtonStyle(
              backgroundColor:
                  WidgetStatePropertyAll(Colors.warningPrimaryColor),
            ),
            onPressed: () async {
              try {
                await dialogContext.read<LinkController>().deleteLink(id);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
              } catch (error) {
                if (!dialogContext.mounted) return;
                await showAppErrorDialog(
                  dialogContext,
                  title: '删除失败',
                  content: '无法删除节目，请稍后重试。\n$error',
                );
              }
            },
            child: const Text('删除'),
          ),
          Button(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
        ],
      );
    },
  );
}

Future<void> showAppErrorDialog(
  BuildContext context, {
  required String title,
  required String content,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return ContentDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          Button(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('确定'),
          ),
        ],
      );
    },
  );
}

Future<void> _submitLink(BuildContext context) async {
  final formController = context.read<LinkFormController>();
  if (!formController.validate()) {
    return;
  }

  final linkController = context.read<LinkController>();

  try {
    if (formController.isEditing) {
      await linkController.updateLink(
        id: formController.editingId!,
        name: formController.trimmedName,
        url: formController.trimmedUrl,
      );
    } else {
      await linkController.addLink(
        name: formController.trimmedName,
        url: formController.trimmedUrl,
      );
    }

    if (!context.mounted) return;
    Navigator.of(context).pop();
  } catch (error) {
    if (!context.mounted) return;
    await showAppErrorDialog(
      context,
      title: formController.isEditing ? '更新失败' : '添加失败',
      content: '保存节目时出现问题，请稍后重试。\n$error',
    );
  }
}
