import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tvshow_nav/app/tvshow_nav_app.dart';
import 'package:tvshow_nav/data/link_store.dart';
import 'package:tvshow_nav/models/link.dart';

void main() {
  testWidgets('空数据时显示空状态', (WidgetTester tester) async {
    await tester.pumpWidget(TvShowNavApp(linkStore: MemoryLinkStore()));
    await tester.pumpAndSettle();

    expect(find.text('电视直播导航'), findsOneWidget);
    expect(find.text('暂无直播链接'), findsOneWidget);
  });

  testWidgets('可以添加编辑并删除节目', (WidgetTester tester) async {
    await tester.pumpWidget(TvShowNavApp(linkStore: MemoryLinkStore()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('添加节目'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextBox).at(0), '新闻频道');
    await tester.enterText(
        find.byType(TextBox).at(1), 'https://example.com/live');
    await tester.tap(find.text('添加'));
    await tester.pumpAndSettle();

    expect(find.text('新闻频道'), findsOneWidget);
    expect(find.text('https://example.com/live'), findsOneWidget);

    await tester.tap(find.byIcon(WindowsIcons.edit));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextBox).at(0), '央视新闻');
    await tester.tap(find.text('更新'));
    await tester.pumpAndSettle();

    expect(find.text('央视新闻'), findsOneWidget);

    await tester.tap(find.byIcon(WindowsIcons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(find.text('央视新闻'), findsNothing);
    expect(find.text('暂无直播链接'), findsOneWidget);
  });

  testWidgets('无效链接会显示明确提示', (WidgetTester tester) async {
    await tester.pumpWidget(
      TvShowNavApp(
        linkStore: MemoryLinkStore(
          initialLinks: [
            TvLink(id: 1, name: '测试节目', url: 'not-a-url'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(WindowsIcons.open_in_new_window));
    await tester.pumpAndSettle();

    expect(find.text('直播链接格式无效，请先在设置里检查这个节目的地址。'), findsOneWidget);
  });
}

class MemoryLinkStore implements LinkStore {
  MemoryLinkStore({List<TvLink>? initialLinks})
      : _links = List<TvLink>.from(initialLinks ?? []);

  final List<TvLink> _links;
  int _nextId = 1;

  @override
  Future<void> initialize() async {
    for (final link in _links) {
      final id = link.id ?? 0;
      if (id >= _nextId) {
        _nextId = id + 1;
      }
    }
  }

  @override
  Future<List<TvLink>> getLinks() async {
    return List<TvLink>.from(_links);
  }

  @override
  Future<TvLink> addLink({
    required String name,
    required String url,
  }) async {
    final link = TvLink(id: _nextId++, name: name, url: url);
    _links.add(link);
    return link;
  }

  @override
  Future<void> updateLink({
    required int id,
    required String name,
    required String url,
  }) async {
    final index = _links.indexWhere((item) => item.id == id);
    _links[index] = TvLink(id: id, name: name, url: url);
  }

  @override
  Future<void> deleteLink(int id) async {
    _links.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> close() async {}
}
