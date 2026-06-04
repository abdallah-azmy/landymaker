import re
import os

filepath = 'lib/features/builder/widgets/editors/block_properties_editor.dart'
blocks_dir = 'lib/features/builder/widgets/editors/blocks'

os.makedirs(blocks_dir, exist_ok=True)

with open(filepath, 'r') as f:
    content = f.read()

# Locate the _buildContentTab body
start_idx = content.find('List<Widget> _buildContentTab')
end_idx = content.find('List<Widget> _buildActionsTab')

if start_idx == -1 or end_idx == -1:
    print("Could not find boundaries")
    exit(1)

content_tab = content[start_idx:end_idx]

# To properly extract each if (type == 'X') block, we'll use a brace matching approach.
# Actually, the code uses `if (type == 'X') ...[`
# We can find all occurrences of `if (type ==`
def find_all_types(text):
    import re
    # Matches: if (type == 'X') ...[  OR if (type == 'X' || type == 'Y') ...[
    pattern = re.compile(r"if\s*\(\s*type\s*==\s*'([^']+)'(?:\s*\|\|\s*type\s*==\s*'([^']+)')?\s*\)\s*\.\.\.\[")
    matches = []
    for m in pattern.finditer(text):
        matches.append({
            'types': [t for t in m.groups() if t],
            'start': m.start(),
            'body_start': m.end() - 1 # points to the `[`
        })
    return matches

matches = find_all_types(content_tab)

blocks_data = []

def get_matching_bracket(text, start_idx):
    count = 0
    for i in range(start_idx, len(text)):
        if text[i] == '[':
            count += 1
        elif text[i] == ']':
            count -= 1
            if count == 0:
                return i
    return -1

for m in matches:
    end_bracket = get_matching_bracket(content_tab, m['body_start'])
    if end_bracket != -1:
        body = content_tab[m['body_start']+1 : end_bracket].strip()
        blocks_data.append({
            'types': m['types'],
            'full_match_start': m['start'],
            'full_match_end': end_bracket + 1, # includes `]`
            'body': body
        })

print(f"Successfully extracted {len(blocks_data)} blocks.")

# Now generate the files
class_template = """import 'package:flutter/material.dart';
import '../../builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import 'package:flutter/services.dart';
import '../../../../../core/widgets/toast_service.dart';

class {class_name}Editor extends StatelessWidget {{
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;

  const {class_name}Editor({{
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
    required this.pickImage,
    required this.pickAndUploadImage,
    super.key,
  }});

  @override
  Widget build(BuildContext context) {{
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        {body}
      ],
    );
  }}
}}
"""

def camel_case(s):
    return ''.join(word.title() for word in s.split('_'))

for b in blocks_data:
    main_type = b['types'][0]
    class_name = camel_case(main_type)
    file_name = f"{main_type}_editor.dart"
    
    # We need to replace `widget.index` with `index`
    body_code = b['body'].replace('widget.index', 'index')
    # We need to replace `_getController` with `getController`
    body_code = body_code.replace('_getController', 'getController')
    # We need to replace `_getFocusNode` with `getFocusNode`
    body_code = body_code.replace('_getFocusNode', 'getFocusNode')
    # Replace `_pickStockImage` with `pickImage`
    body_code = body_code.replace('_pickStockImage', 'pickImage')
    # Replace `_pickAndUploadImage` with `pickAndUploadImage`
    body_code = body_code.replace('_pickAndUploadImage', 'pickAndUploadImage')
    # Replace `widget.state` with `cubit.state`
    body_code = body_code.replace('widget.state', 'cubit.state')

    with open(os.path.join(blocks_dir, file_name), 'w') as f:
        f.write(class_template.format(class_name=class_name, body=body_code))
    print(f"Created {file_name}")

# Now we need to modify block_properties_editor.dart
# Replace the old extraction blocks with new class calls
new_content_tab = content_tab
# Replace from bottom up to avoid messing up indices
for b in reversed(blocks_data):
    main_type = b['types'][0]
    class_name = camel_case(main_type)
    
    # If there are multiple types (e.g. hero || hero_saas), handle it
    condition = " || ".join([f"type == '{t}'" for t in b['types']])
    
    replacement = f"if ({condition}) ...[\n      {class_name}Editor(\n        cubit: cubit,\n        block: block,\n        index: widget.index,\n        getController: _getController,\n        getFocusNode: _getFocusNode,\n        pickImage: _pickStockImage,\n        pickAndUploadImage: _pickAndUploadImage,\n      ),\n    ]"
    
    new_content_tab = new_content_tab[:b['full_match_start']] + replacement + new_content_tab[b['full_match_end']:]

# Add imports to the top of block_properties_editor.dart
imports = "import 'editor_types.dart';\n"
for b in blocks_data:
    main_type = b['types'][0]
    imports += f"import 'blocks/{main_type}_editor.dart';\n"

# Rewrite the main file
final_content = content[:start_idx] + new_content_tab + content[end_idx:]

# Find the last import and insert our new imports
import_end = final_content.rfind("import ")
next_newline = final_content.find("\n", import_end)
final_content = final_content[:next_newline+1] + imports + final_content[next_newline+1:]

with open(filepath, 'w') as f:
    f.write(final_content)

print("Main file refactored successfully.")
