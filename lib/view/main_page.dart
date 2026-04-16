import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:tvshow_nav/components/home_page.dart';
import 'package:tvshow_nav/components/manage_page.dart';
import 'package:tvshow_nav/controllers/link_controller.dart';
import 'package:tvshow_nav/controllers/navigation_controller.dart';
import 'package:tvshow_nav/theme.dart';
import 'package:tvshow_nav/view/dialogs.dart';
import 'package:window_manager/window_manager.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    final navigationController = context.watch<NavigationController>();
    final linkController = context.watch<LinkController>();
    final theme = FluentTheme.of(context);

    return NavigationView(
      titleBar: SizedBox(
        height: 48,
        child: Row(
          children: [
            Expanded(
              child: DragToMoveArea(
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(start: 12),
                    child: Text('电视直播导航'),
                  ),
                ),
              ),
            ),
            _ThemeButton(appTheme: appTheme),
            const SizedBox(width: 8),
            SizedBox(
              width: 138,
              height: 48,
              child: WindowCaption(
                brightness: theme.brightness,
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
      pane: NavigationPane(
        displayMode: PaneDisplayMode.top,
        selected: navigationController.selectedIndex,
        onChanged: navigationController.setSelectedIndex,
        items: [
          PaneItem(
            icon: const Icon(WindowsIcons.home),
            title: const Text('首页'),
            body: HomePage(
              links: linkController.links,
              loadState: linkController.loadState,
              errorMessage: linkController.errorMessage,
              onRetry: () => context.read<LinkController>().retryInitialize(),
            ),
          ),
          PaneItem(
            icon: const Icon(WindowsIcons.settings),
            title: const Text('设置'),
            body: ManagePage(
              links: linkController.links,
              loadState: linkController.loadState,
              errorMessage: linkController.errorMessage,
              onAdd: () => showLinkEditorDialog(context),
              onEdit: (id) => showLinkEditorDialog(context, editingId: id),
              onDelete: (id) => showDeleteDialog(context, id),
              onRetry: () => context.read<LinkController>().retryInitialize(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  const _ThemeButton({required this.appTheme});

  final AppTheme appTheme;

  @override
  Widget build(BuildContext context) {
    return DropDownButton(
      leading: const Icon(FluentIcons.sunny),
      title: Text(_currentThemeText(appTheme.mode)),
      items: [
        _buildThemeMenuItem(context, ThemeMode.system, '跟随系统'),
        _buildThemeMenuItem(context, ThemeMode.light, '亮色'),
        _buildThemeMenuItem(context, ThemeMode.dark, '暗色'),
      ],
    );
  }

  String _currentThemeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '亮色';
      case ThemeMode.dark:
        return '暗色';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  MenuFlyoutItem _buildThemeMenuItem(
    BuildContext context,
    ThemeMode mode,
    String text,
  ) {
    return MenuFlyoutItem(
      text: Text(text),
      onPressed: () => context.read<AppTheme>().mode = mode,
    );
  }
}
