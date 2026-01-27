import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tvshow_nav/db/db_helper.dart';
import 'package:tvshow_nav/models/link.dart';
import 'package:tvshow_nav/components/home_page.dart';
import 'package:tvshow_nav/components/manage_page.dart';
import 'package:tvshow_nav/theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppTheme(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  bool _isManagePage = false;
  bool _dbInitialized = false;
  List<TvLink> _links = [];

  int _editId = 0;
  String _editName = '';
  String _editUrl = '';

  @override
  void initState() {
    super.initState();
    _checkAndInitDatabase();
  }

  Future<void> _checkAndInitDatabase() async {
    final dbPath = DbHelper.instance.getDbPath();
    final exists = await File(dbPath).exists();
    if (exists) {
      if (!mounted) return;
      setState(() {
        _dbInitialized = true;
      });
      await _loadLinks();
    } else {
      if (!mounted) return;
      setState(() {
        _dbInitialized = false;
      });
    }
  }

  Future<void> _loadLinks() async {
    final links = await DbHelper.instance.getLinks();
    if (!mounted) return;
    setState(() {
      _links = links;
    });
  }

  Future<void> _addLink() async {
    if (_editName.trim().isEmpty || _editUrl.trim().isEmpty) {
      return;
    }

    final newLink = TvLink(id: 0, name: _editName, url: _editUrl);
    await DbHelper.instance.addLink(newLink);
    await _loadLinks();
    if (!mounted) return;
    Navigator.of(context).pop();
    _resetEditFields();
  }

  Future<void> _updateLink() async {
    if (_editName.trim().isEmpty || _editUrl.trim().isEmpty) {
      return;
    }

    final updatedLink = TvLink(id: _editId, name: _editName, url: _editUrl);
    await DbHelper.instance.updateLink(updatedLink);
    await _loadLinks();
    if (!mounted) return;
    Navigator.of(context).pop();
    _resetEditFields();
  }

  Future<void> _deleteLink() async {
    await DbHelper.instance.deleteLink(_editId);
    await _loadLinks();
    if (!mounted) return;
    Navigator.of(context).pop();
    _resetEditFields();
  }

  void _showAddDialog() {
    _resetEditFields();
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        actions: <Widget>[
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: _addLink,
            child: const Text('添加'),
          ),
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoLabel(
              label: '节目名称',
              child: TextBox(
                placeholder: '请输入节目名称',
                onChanged: (value) => setState(() => _editName = value),
              ),
            ),
            const SizedBox(height: 12),
            InfoLabel(
              label: '直播链接',
              child: TextBox(
                placeholder: '请输入直播链接',
                onChanged: (value) => setState(() => _editUrl = value),
              ),
            ),
          ],
        ),
        title: const Text('添加新节目'),
      ),
    );
  }

  void _showEditDialog(int id) {
    final link = _links.firstWhere((l) => l.id == id);
    _editId = link.id;
    _editName = link.name;
    _editUrl = link.url;
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        actions: <Widget>[
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: _updateLink,
            child: const Text('更新'),
          ),
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoLabel(
              label: '节目名称',
              child: TextBox(
                placeholder: '请输入节目名称',
                controller: TextEditingController(text: _editName)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: _editName.length),
                  ),
                onChanged: (value) => setState(() => _editName = value),
              ),
            ),
            const SizedBox(height: 12),
            InfoLabel(
              label: '直播链接',
              child: TextBox(
                placeholder: '请输入直播链接',
                controller: TextEditingController(text: _editUrl)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: _editUrl.length),
                  ),
                onChanged: (value) => setState(() => _editUrl = value),
              ),
            ),
          ],
        ),
        title: const Text('编辑节目'),
      ),
    );
  }

  void _showDeleteDialog(int id) {
    final link = _links.firstWhere((l) => l.id == id);
    _editId = link.id;
    _editName = link.name;
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        actions: <Widget>[
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: _deleteLink,
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Color(0xFFFF0000)),
            ),
            child: const Text('删除'),
          ),
        ],
        content: Text('确定要删除节目 $_editName 吗？此操作不可恢复。'),
        title: const Text('确认删除'),
      ),
    );
  }

  void _resetEditFields() {
    _editId = 0;
    _editName = '';
    _editUrl = '';
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return NavigationView(
      pane: NavigationPane(
        displayMode: PaneDisplayMode.top,
        selected: _isManagePage ? 1 : 0,
        onChanged: (index) {
          setState(() {
            _isManagePage = index == 1;
          });
        },
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Text(
                '电视直播导航',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 16),
              _buildThemeButton(appTheme),
            ],
          ),
        ),
        items: [
          PaneItem(
            icon: const Icon(WindowsIcons.home),
            title: const Text('首页'),
            body: HomePage(
              dbInitialized: _dbInitialized,
              links: _links,
            ),
          ),
          PaneItem(
            icon: const Icon(WindowsIcons.settings),
            title: const Text('设置'),
            body: ManagePage(
              dbInitialized: _dbInitialized,
              links: _links,
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
    final isSelected = context.watch<AppTheme>().mode == mode;
    return MenuFlyoutItem(
      text: Row(
        children: [
          if (isSelected)
            Icon(
              WindowsIcons.check_mark,
              size: 14,
              color: FluentTheme.of(context).accentColor,
            ),
          if (isSelected) const SizedBox(width: 8),
          Text(text),
        ],
      ),
      onPressed: () => context.read<AppTheme>().mode = mode,
    );
  }
}
