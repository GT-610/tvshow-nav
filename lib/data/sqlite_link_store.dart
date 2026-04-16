import 'package:tvshow_nav/data/link_store.dart';
import 'package:tvshow_nav/db/db_helper.dart';
import 'package:tvshow_nav/models/link.dart';

class SqliteLinkStore implements LinkStore {
  SqliteLinkStore({DbHelper? dbHelper})
      : _dbHelper = dbHelper ?? DbHelper.instance;

  final DbHelper _dbHelper;

  @override
  Future<void> initialize() async {
    await _dbHelper.initDatabase();
  }

  @override
  Future<List<TvLink>> getLinks() {
    return _dbHelper.getLinks();
  }

  @override
  Future<TvLink> addLink({
    required String name,
    required String url,
  }) {
    return _dbHelper.addLink(
      TvLink(
        name: name,
        url: url,
      ),
    );
  }

  @override
  Future<void> updateLink({
    required int id,
    required String name,
    required String url,
  }) async {
    await _dbHelper.updateLink(
      TvLink(
        id: id,
        name: name,
        url: url,
      ),
    );
  }

  @override
  Future<void> deleteLink(int id) async {
    await _dbHelper.deleteLink(id);
  }

  @override
  Future<void> close() {
    return _dbHelper.close();
  }
}
