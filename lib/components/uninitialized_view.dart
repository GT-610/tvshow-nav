import 'package:fluent_ui/fluent_ui.dart';
import 'package:tvshow_nav/db/db_helper.dart';

class UninitializedView extends StatelessWidget {
  const UninitializedView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;
    return Center(
      child: Card(
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FluentIcons.database,
                size: 48,
                color: isDark ? Colors.white : Colors.black,
              ),
              const SizedBox(height: 16),
              const Text(
                '数据库尚未初始化',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text(
                '点击下方按钮初始化数据库',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  await DbHelper.instance.initDatabase();
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                child: const Text('初始化数据库'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
