import 'package:fluent_ui/fluent_ui.dart';
import 'package:tvshow_nav/models/link.dart';

class LinkFormController extends ChangeNotifier {
  int? _editingId;
  String _name = '';
  String _url = '';
  String? _nameError;
  String? _urlError;
  bool _showErrors = false;

  bool get isEditing => _editingId != null;
  int? get editingId => _editingId;
  String get name => _name;
  String get url => _url;
  String? get nameError => _nameError;
  String? get urlError => _urlError;

  void startCreate() {
    _editingId = null;
    _name = '';
    _url = '';
    _nameError = null;
    _urlError = null;
    _showErrors = false;
    notifyListeners();
  }

  void startEdit(TvLink link) {
    _editingId = link.id;
    _name = link.name;
    _url = link.url;
    _nameError = null;
    _urlError = null;
    _showErrors = false;
    notifyListeners();
  }

  void setName(String value) {
    _name = value;
    if (_showErrors) {
      _validateName();
    }
    notifyListeners();
  }

  void setUrl(String value) {
    _url = value;
    if (_showErrors) {
      _validateUrl();
    }
    notifyListeners();
  }

  bool validate() {
    _showErrors = true;
    _validateName();
    _validateUrl();
    notifyListeners();
    return _nameError == null && _urlError == null;
  }

  String get trimmedName => _name.trim();
  String get trimmedUrl => _url.trim();

  void _validateName() {
    _nameError = trimmedName.isEmpty ? '请输入节目名称。' : null;
  }

  void _validateUrl() {
    final url = trimmedUrl;
    if (url.isEmpty) {
      _urlError = '请输入直播链接。';
      return;
    }

    final uri = Uri.tryParse(url);
    final hasSupportedScheme = uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
    _urlError = hasSupportedScheme ? null : '请输入有效的 http 或 https 链接。';
  }
}
