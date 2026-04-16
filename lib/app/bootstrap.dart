import 'package:flutter/widgets.dart';
import 'package:tvshow_nav/app/tvshow_nav_app.dart';
import 'package:window_manager/window_manager.dart';

Future<void> bootstrapApp() async {
  await WindowManager.instance.ensureInitialized();
  await WindowManager.instance.setTitleBarStyle(
    TitleBarStyle.hidden,
    windowButtonVisibility: true,
  );
  await WindowManager.instance.setMinimumSize(const Size(500, 600));

  runApp(const TvShowNavApp());
}
