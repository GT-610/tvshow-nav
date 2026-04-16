import 'package:tvshow_nav/models/link.dart';

abstract class LinkStore {
  Future<void> initialize();
  Future<List<TvLink>> getLinks();
  Future<TvLink> addLink({
    required String name,
    required String url,
  });
  Future<void> updateLink({
    required int id,
    required String name,
    required String url,
  });
  Future<void> deleteLink(int id);
  Future<void> close();
}
