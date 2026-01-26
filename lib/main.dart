import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tvshow_nav/db/db_helper.dart';
import 'package:tvshow_nav/models/link.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: '电视直播导航',
      theme: FluentThemeData(brightness: Brightness.light),
      darkTheme: FluentThemeData(brightness: Brightness.dark),
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

  static const Color accentColor = Color(0xFF0078D4);

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

  Future<void> _initDatabase() async {
    await DbHelper.instance.initDatabase();
    if (!mounted) return;
    setState(() {
      _dbInitialized = true;
    });
    await _loadLinks();
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

  void _openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
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

  Widget _buildUninitializedView() {
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;
    return Center(
      child: Card(
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FluentIcons.database,
                size: 48,
                color: isDark ? Colors.white : Colors.black,
              ),
              const SizedBox(height: 16),
              const Text(
                '数据库尚未初始化',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text(
                '点击下方按钮初始化数据库',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _initDatabase,
                child: const Text('初始化数据库'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkCard(TvLink link, bool isManageMode) {
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;
    return Card(
      borderRadius: BorderRadius.circular(8),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              WindowsIcons.video,
              color: accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  link.url,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[20] : Colors.grey[80],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: '打开链接',
            child: IconButton(
              icon: const Icon(FluentIcons.open_in_new_window),
              onPressed: () => _openUrl(link.url),
            ),
          ),
          if (isManageMode) ...[
            Tooltip(
              message: '编辑',
              child: IconButton(
                icon: const Icon(FluentIcons.edit),
                onPressed: () => _showEditDialog(link.id),
              ),
            ),
            Tooltip(
              message: '删除',
              child: IconButton(
                icon: const Icon(FluentIcons.delete),
                onPressed: () => _showDeleteDialog(link.id),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    if (!_dbInitialized) {
      return _buildUninitializedView();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Expanded(
        child: _links.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FluentIcons.video,
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
                      style: TextStyle(
                        color: Colors.grey[60],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _links.length,
                itemBuilder: (context, index) {
                  final link = _links[index];
                  return _buildLinkCard(link, false);
                },
              ),
      ),
    );
  }

  Widget _buildManagePage() {
    if (!_dbInitialized) {
      return _buildUninitializedView();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommandBar(
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.add),
                label: const Text('添加节目'),
                onPressed: _showAddDialog,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Expanded(
            child: _links.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FluentIcons.list,
                        size: 64,
                        color: Colors.grey[40],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无直播链接',
                        style: FluentTheme.of(context).typography.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: _showAddDialog,
                        child: const Text('添加第一个节目'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _links.length,
                  itemBuilder: (context, index) {
                    final link = _links[index];
                    return _buildLinkCard(link, true);
                  },
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(
        title: Text('电视直播导航'),
      ),
      pane: NavigationPane(
        displayMode: PaneDisplayMode.top,
        selected: _isManagePage ? 1 : 0,
        onChanged: (index) {
          setState(() {
            _isManagePage = index == 1;
          });
        },
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text('首页'),
            body: _buildHomePage(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('管理节目'),
            body: _buildManagePage(),
          ),
        ],
      ),
    );
  }
}
