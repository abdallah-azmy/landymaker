import re

filepath = 'lib/features/builder/registries/block_registry.dart'

with open(filepath, 'r') as f:
    content = f.read()

import_statement = "import '../../public_viewer/widgets/custom_multi_step_form_widget.dart';\n"
last_import_idx = content.rfind("import '")
next_newline_idx = content.find('\n', last_import_idx)

content = content[:next_newline_idx+1] + import_statement + content[next_newline_idx+1:]

registry_pattern = "static final Map<String, BlockBuilder> _registry = {"
registry_idx = content.find(registry_pattern)

multi_step_code = """
    'multi_step_lead_form': (data, theme, pageId, key, __, ___) => CustomMultiStepFormWidget(
      key: key,
      block: data,
      theme: theme,
      pageId: pageId,
    ),"""

content = content[:registry_idx + len(registry_pattern)] + multi_step_code + content[registry_idx + len(registry_pattern):]

with open(filepath, 'w') as f:
    f.write(content)

print("Updated block_registry.dart")
