import 'package:fluent_ui/fluent_ui.dart';
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
  List<TvLink> _links = [];

  int _editId = 0;
  String _editName = '';
  String _editUrl = '';

  static const Color linkColor = Color(0xFF0078D4);
  static const Color greyColor = Color(0x33AAAAAA);
  static const Color redColor = Color(0xFFFF0000);

  @override
  void initState() {
    super.initState();
    _loadLinks();
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
          children: [
            InfoLabel(
              label: '节目名称',
              child: TextBox(
                placeholder: '请输入节目名称',
                onChanged: (value) => setState(() => _editName = value),
              ),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
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
              backgroundColor: WidgetStatePropertyAll(redColor),
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

  Widget _buildHomePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('轻松跳转到您喜爱的电视台直播',
            style: FluentTheme.of(context).typography.body),
        const SizedBox(height: 10),
        Expanded(
          child: _links.isEmpty
              ? const Center(child: Text('暂无直播链接'))
              : Table(
                  border: TableBorder.all(),
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: greyColor),
                      children: [
                        TableCell(child: Center(child: Text('编号'))),
                        TableCell(child: Center(child: Text('节目名称'))),
                        TableCell(child: Center(child: Text('直播链接'))),
                      ],
                    ),
                    for (var link in _links)
                      TableRow(
                        children: [
                          TableCell(child: Center(child: Text('${link.id}'))),
                          TableCell(child: Center(child: Text(link.name))),
                          TableCell(
                            child: Center(
                              child: GestureDetector(
                                onTap: () => _openUrl(link.url),
                                child: Text(
                                  link.url,
                                  style: const TextStyle(color: linkColor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildManagePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('节目列表', style: FluentTheme.of(context).typography.title),
            FilledButton(
              onPressed: _showAddDialog,
              child: const Text('添加节目'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _links.isEmpty
              ? const Center(child: Text('暂无直播链接'))
              : Table(
                  border: TableBorder.all(),
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: greyColor),
                      children: [
                        TableCell(child: Center(child: Text('编号'))),
                        TableCell(child: Center(child: Text('节目名称'))),
                        TableCell(child: Center(child: Text('直播链接'))),
                        TableCell(child: Center(child: Text('操作'))),
                      ],
                    ),
                    for (var link in _links)
                      TableRow(
                        children: [
                          TableCell(child: Center(child: Text('${link.id}'))),
                          TableCell(child: Center(child: Text(link.name))),
                          TableCell(
                            child: Center(
                              child: GestureDetector(
                                onTap: () => _openUrl(link.url),
                                child: Text(
                                  link.url,
                                  style: const TextStyle(color: linkColor),
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  HyperlinkButton(
                                    onPressed: () => _showEditDialog(link.id),
                                    child: const Text('编辑'),
                                  ),
                                  const SizedBox(width: 10),
                                  HyperlinkButton(
                                    onPressed: () => _showDeleteDialog(link.id),
                                    child: const Text('删除'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
        ),
      ],
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
