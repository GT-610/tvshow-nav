import 'package:fluent_ui/fluent_ui.dart';
import 'package:tvshow_nav/data/link_store.dart';
import 'package:tvshow_nav/models/link.dart';

class LinkController extends ChangeNotifier {
  LinkController({required LinkStore linkStore}) : _linkStore = linkStore;

  final LinkStore _linkStore;
  List<TvLink> _links = [];
  bool _isLoading = false;

  List<TvLink> get links => _links;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _linkStore.initialize();
      await loadLinks(notify: false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLinks({bool notify = true}) async {
    _links = await _linkStore.getLinks();
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> addLink({
    required String name,
    required String url,
  }) async {
    final link = await _linkStore.addLink(name: name, url: url);
    _links = [..._links, link];
    notifyListeners();
  }

  Future<void> updateLink({
    required int id,
    required String name,
    required String url,
  }) async {
    await _linkStore.updateLink(id: id, name: name, url: url);
    final index = _links.indexWhere((item) => item.id == id);
    if (index == -1) {
      await loadLinks();
      return;
    }

    final updatedLinks = List<TvLink>.from(_links);
    updatedLinks[index] = updatedLinks[index].copyWith(name: name, url: url);
    _links = updatedLinks;
    notifyListeners();
  }

  Future<void> deleteLink(int id) async {
    await _linkStore.deleteLink(id);
    final nextLinks = _links.where((item) => item.id != id).toList();
    if (nextLinks.length == _links.length) {
      await loadLinks();
      return;
    }

    _links = nextLinks;
    notifyListeners();
  }
}
