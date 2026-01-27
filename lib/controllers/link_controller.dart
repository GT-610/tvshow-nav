import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:tvshow_nav/db/db_helper.dart';
import 'package:tvshow_nav/models/link.dart';

class LinkController extends ChangeNotifier {
  List<TvLink> _links = [];
  bool _isManagePage = false;

  List<TvLink> get links => _links;
  bool get isManagePage => _isManagePage;

  void setManagePage(bool value) {
    _isManagePage = value;
    notifyListeners();
  }

  Future<void> initialize() async {
    final dbPath = DbHelper.instance.getDbPath();
    final exists = await File(dbPath).exists();
    if (!exists) {
      await DbHelper.instance.initDatabase();
    } else {
      await loadLinks();
    }
    notifyListeners();
  }

  Future<void> loadLinks() async {
    _links = await DbHelper.instance.getLinks();
    notifyListeners();
  }

  Future<void> addLink(String name, String url) async {
    if (name.trim().isEmpty || url.trim().isEmpty) {
      return;
    }

    final newLink = TvLink(id: 0, name: name, url: url);
    await DbHelper.instance.addLink(newLink);
    await loadLinks();
  }

  Future<void> updateLink(int id, String name, String url) async {
    if (name.trim().isEmpty || url.trim().isEmpty) {
      return;
    }

    final updatedLink = TvLink(id: id, name: name, url: url);
    await DbHelper.instance.updateLink(updatedLink);
    await loadLinks();
  }

  Future<void> deleteLink(int id) async {
    await DbHelper.instance.deleteLink(id);
    await loadLinks();
  }

  int _editId = 0;
  String _editName = '';
  String _editUrl = '';

  int get editId => _editId;
  String get editName => _editName;
  String get editUrl => _editUrl;

  void setEditFields(int id, String name, String url) {
    _editId = id;
    _editName = name;
    _editUrl = url;
    notifyListeners();
  }

  void clearEditFields() {
    _editId = 0;
    _editName = '';
    _editUrl = '';
    notifyListeners();
  }

  void setEditName(String name) {
    _editName = name;
    notifyListeners();
  }

  void setEditUrl(String url) {
    _editUrl = url;
    notifyListeners();
  }

  bool validateInputs([String? name, String? url]) {
    final inputName = name ?? _editName;
    final inputUrl = url ?? _editUrl;
    return inputName.trim().isNotEmpty && inputUrl.trim().isNotEmpty;
  }
}
