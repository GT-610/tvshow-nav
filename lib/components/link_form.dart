import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:tvshow_nav/controllers/link_form_controller.dart';

class LinkForm extends StatefulWidget {
  const LinkForm({
    super.key,
  });

  @override
  State<LinkForm> createState() => _LinkFormState();
}

class _LinkFormState extends State<LinkForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    final formController = context.read<LinkFormController>();
    _nameController = TextEditingController(text: formController.name);
    _urlController = TextEditingController(text: formController.url);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formController = context.watch<LinkFormController>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoLabel(
          label: '节目名称',
          child: TextBox(
            placeholder: '请输入节目名称',
            controller: _nameController,
            onChanged: formController.setName,
          ),
        ),
        if (formController.nameError != null) ...[
          const SizedBox(height: 6),
          Text(
            formController.nameError!,
            style: TextStyle(color: Colors.red),
          ),
        ],
        const SizedBox(height: 12),
        InfoLabel(
          label: '直播链接',
          child: TextBox(
            placeholder: '请输入直播链接',
            controller: _urlController,
            onChanged: formController.setUrl,
          ),
        ),
        if (formController.urlError != null) ...[
          const SizedBox(height: 6),
          Text(
            formController.urlError!,
            style: TextStyle(color: Colors.red),
          ),
        ],
      ],
    );
  }
}
