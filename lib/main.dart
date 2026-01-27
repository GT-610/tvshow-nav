import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tvshow_nav/controllers/link_controller.dart';
import 'package:tvshow_nav/db/db_helper.dart';
import 'package:tvshow_nav/components/home_page.dart';
import 'package:tvshow_nav/components/link_form.dart';
import 'package:tvshow_nav/components/manage_page.dart';
import 'package:tvshow_nav/theme.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowManager.instance.ensureInitialized();
  await WindowManager.instance.setTitleBarStyle(
    TitleBarStyle.hidden,
    windowButtonVisibility: true,
  );
  await WindowManager.instance.setMinimumSize(const Size(500, 600));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppTheme()),
        ChangeNotifierProvider(create: (context) => LinkController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DbHelper.instance.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      DbHelper.instance.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return FluentApp(
      title: '电视直播导航',
      theme: FluentThemeData(brightness: Brightness.light),
      darkTheme: FluentThemeData(brightness: Brightness.dark),
      themeMode: appTheme.mode,
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [
        Locale('zh', 'CN'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _urlController = TextEditingController();
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<LinkController>().initialize();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    if (!mounted) return;
    _nameController.clear();
    _urlController.clear();
    context.read<LinkController>().clearEditFields();
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        actions: <Widget>[
          FilledButton(
            onPressed: () => _addLink(),
            child: const Text('添加'),
          ),
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
        content: LinkForm(
          nameController: _nameController,
          urlController: _urlController,
          onNameChanged: (value) {
            context.read<LinkController>().setEditName(value);
          },
          onUrlChanged: (value) {
            context.read<LinkController>().setEditUrl(value);
          },
        ),
        title: const Text('添加新节目'),
      ),
    );
  }

  void _showEditDialog(int id) {
    if (!mounted) return;
    final controller = context.read<LinkController>();
    final link = controller.links.firstWhere((l) => l.id == id);
    controller.setEditFields(link.id, link.name, link.url);
    _nameController.text = link.name;
    _nameController.selection = TextSelection.fromPosition(
      TextPosition(offset: link.name.length),
    );
    _urlController.text = link.url;
    _urlController.selection = TextSelection.fromPosition(
      TextPosition(offset: link.url.length),
    );
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        actions: <Widget>[
          FilledButton(
            onPressed: () => _updateLink(),
            child: const Text('更新'),
          ),
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
        content: LinkForm(
          nameController: _nameController,
          urlController: _urlController,
          onNameChanged: (value) {
            context.read<LinkController>().setEditName(value);
          },
          onUrlChanged: (value) {
            context.read<LinkController>().setEditUrl(value);
          },
        ),
        title: const Text('编辑节目'),
      ),
    );
  }

  void _showDeleteDialog(int id) {
    if (!mounted) return;
    final controller = context.read<LinkController>();
    final link = controller.links.firstWhere((l) => l.id == id);
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        actions: <Widget>[
          FilledButton(
            onPressed: () => _deleteLink(id),
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.warningPrimaryColor),
            ),
            child: const Text('删除'),
          ),
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
        content: Text('确定要删除节目 ${link.name} 吗？此操作不可恢复。'),
        title: const Text('确认删除'),
      ),
    );
  }

  Future<void> _addLink() async {
    final controller = context.read<LinkController>();
    if (!controller.validateInputs()) {
      return;
    }

    try {
      await controller.addLink(controller.editName, controller.editUrl);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('添加失败', '无法添加节目: $e');
    }
  }

  Future<void> _updateLink() async {
    final controller = context.read<LinkController>();
    if (!controller.validateInputs()) {
      return;
    }

    try {
      await controller.updateLink(controller.editId, controller.editName, controller.editUrl);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('更新失败', '无法更新节目: $e');
    }
  }

  Future<void> _deleteLink(int id) async {
    try {
      await context.read<LinkController>().deleteLink(id);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('删除失败', '无法删除节目: $e');
    }
  }

  void _showErrorDialog(String title, String content) {
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        actions: <Widget>[
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
        content: Text(content),
        title: Text(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    final theme = FluentTheme.of(context);
    final linkController = context.watch<LinkController>();
    return NavigationView(
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        title: DragToMoveArea(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                const Text('电视直播导航'),
              ],
            ),
          ),
        ),
        actions: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildThemeButton(appTheme),
            const SizedBox(width: 8),
            SizedBox(
              width: 138,
              height: 50,
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
        selected: linkController.isManagePage ? 1 : 0,
        onChanged: (index) {
          context.read<LinkController>().setManagePage(index == 1);
        },
        items: [
          PaneItem(
            icon: const Icon(WindowsIcons.home),
            title: const Text('首页'),
            body: HomePage(
              dbInitialized: linkController.dbInitialized,
              links: linkController.links,
            ),
          ),
          PaneItem(
            icon: const Icon(WindowsIcons.settings),
            title: const Text('设置'),
            body: ManagePage(
              dbInitialized: linkController.dbInitialized,
              links: linkController.links,
              onAdd: _showAddDialog,
              onEdit: _showEditDialog,
              onDelete: _showDeleteDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton(AppTheme appTheme) {
    final menuChildren = [
      _buildThemeMenuItem(ThemeMode.system, '跟随系统'),
      _buildThemeMenuItem(ThemeMode.light, '亮色'),
      _buildThemeMenuItem(ThemeMode.dark, '暗色'),
    ];

    String currentThemeText = '跟随系统';
    switch (appTheme.mode) {
      case ThemeMode.light:
        currentThemeText = '亮色';
        break;
      case ThemeMode.dark:
        currentThemeText = '暗色';
        break;
      case ThemeMode.system:
        currentThemeText = '跟随系统';
        break;
    }

    return DropDownButton(
      leading: const Icon(FluentIcons.sunny),
      title: Text(currentThemeText),
      items: menuChildren,
    );
  }

  MenuFlyoutItem _buildThemeMenuItem(ThemeMode mode, String text) {
    return MenuFlyoutItem(
      text: Text(text),
      onPressed: () => context.read<AppTheme>().mode = mode,
    );
  }
}
