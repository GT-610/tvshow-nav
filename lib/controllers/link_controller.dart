import 'package:fluent_ui/fluent_ui.dart';
import 'package:tvshow_nav/data/link_store.dart';
import 'package:tvshow_nav/models/link.dart';

enum LinkLoadState {
  loading,
  ready,
  error,
}

class LinkController extends ChangeNotifier {
  LinkController({required LinkStore linkStore}) : _linkStore = linkStore;

  final LinkStore _linkStore;
  List<TvLink> _links = [];
  LinkLoadState _loadState = LinkLoadState.loading;
  String? _errorMessage;

  List<TvLink> get links => _links;
  LinkLoadState get loadState => _loadState;
  bool get isLoading => _loadState == LinkLoadState.loading;
  bool get hasError => _loadState == LinkLoadState.error;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _setLoadingState();
    notifyListeners();

    try {
      await _linkStore.initialize();
      await loadLinks(notify: false);
      _setReadyState();
    } catch (error) {
      _setErrorState(_buildLoadErrorMessage(error));
    } finally {
      notifyListeners();
    }
  }

  Future<void> retryInitialize() async {
    await initialize();
  }

  Future<void> loadLinks({bool notify = true}) async {
    try {
      _links = await _linkStore.getLinks();
      _setReadyState();
    } catch (error) {
      _setErrorState(_buildLoadErrorMessage(error));
      rethrow;
    }

    if (notify) {
      notifyListeners();
    }
  }

  Future<void> addLink({
    required String name,
    required String url,
  }) async {
    await _linkStore.addLink(name: name, url: url);
    await loadLinks();
  }

  Future<void> updateLink({
    required int id,
    required String name,
    required String url,
  }) async {
    await _linkStore.updateLink(id: id, name: name, url: url);
    await loadLinks();
  }

  Future<void> deleteLink(int id) async {
    await _linkStore.deleteLink(id);
    await loadLinks();
  }

  void _setLoadingState() {
    _loadState = LinkLoadState.loading;
    _errorMessage = null;
  }

  void _setReadyState() {
    _loadState = LinkLoadState.ready;
    _errorMessage = null;
  }

  void _setErrorState(String message) {
    _loadState = LinkLoadState.error;
    _errorMessage = message;
  }

  String _buildLoadErrorMessage(Object error) {
    return '读取节目列表失败，请稍后重试。\n$error';
  }
}
