import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tvshow_nav/controllers/link_controller.dart';
import 'package:tvshow_nav/controllers/link_form_controller.dart';
import 'package:tvshow_nav/controllers/navigation_controller.dart';
import 'package:tvshow_nav/data/link_store.dart';
import 'package:tvshow_nav/data/sqlite_link_store.dart';
import 'package:tvshow_nav/theme.dart';
import 'package:tvshow_nav/view/main_page.dart';

class TvShowNavApp extends StatefulWidget {
  const TvShowNavApp({
    super.key,
    this.linkStore,
  });

  final LinkStore? linkStore;

  @override
  State<TvShowNavApp> createState() => _TvShowNavAppState();
}

class _TvShowNavAppState extends State<TvShowNavApp>
    with WidgetsBindingObserver {
  late final LinkStore _linkStore;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _linkStore = widget.linkStore ?? SqliteLinkStore();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkStore.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      _linkStore.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LinkStore>.value(value: _linkStore),
        ChangeNotifierProvider(create: (_) => AppTheme()),
        ChangeNotifierProvider(create: (_) => NavigationController()),
        ChangeNotifierProvider(create: (_) => LinkFormController()),
        ChangeNotifierProvider(
          create: (context) =>
              LinkController(linkStore: context.read<LinkStore>())
                ..initialize(),
        ),
      ],
      child: Builder(
        builder: (context) {
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
        },
      ),
    );
  }
}
