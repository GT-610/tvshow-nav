import 'package:fluent_ui/fluent_ui.dart';

class LinkForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController urlController;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onUrlChanged;

  const LinkForm({
    super.key,
    required this.nameController,
    required this.urlController,
    required this.onNameChanged,
    required this.onUrlChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoLabel(
          label: '节目名称',
          child: TextBox(
            placeholder: '请输入节目名称',
            controller: nameController,
            onChanged: onNameChanged,
          ),
        ),
        const SizedBox(height: 12),
        InfoLabel(
          label: '直播链接',
          child: TextBox(
            placeholder: '请输入直播链接',
            controller: urlController,
            onChanged: onUrlChanged,
          ),
        ),
      ],
    );
  }
}
