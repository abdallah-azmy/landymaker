import re

filepath = 'lib/features/builder/widgets/editors/block_properties_editor.dart'

with open(filepath, 'r') as f:
    content = f.read()

start_idx = content.find('List<Widget> _buildContentTab')
end_idx = content.find('List<Widget> _buildActionsTab')

content_tab = content[start_idx:end_idx]

def find_all_types(text):
    pattern = re.compile(r"if\s*\(\s*type\s*==\s*'([^']+)'(?:\s*\|\|\s*type\s*==\s*'([^']+)')?\s*\)\s*\.\.\.\[")
    matches = []
    for m in pattern.finditer(text):
        matches.append({
            'types': [t for t in m.groups() if t],
            'start': m.start(),
            'body_start': m.end() - 1
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
        blocks_data.append({
            'types': m['types'],
            'full_match_start': m['start'],
            'full_match_end': end_bracket + 1, # includes `]`
        })

def camel_case(s):
    return ''.join(word.title() for word in s.split('_'))

new_content_tab = content_tab
for b in reversed(blocks_data):
    main_type = b['types'][0]
    class_name = camel_case(main_type)
    condition = " || ".join([f"type == '{t}'" for t in b['types']])
    
    # ADDING THE COMMA AFTER ] !!!
    replacement = f"if ({condition}) ...[\n      {class_name}Editor(\n        cubit: cubit,\n        block: block,\n        index: widget.index,\n        getController: _getController,\n        getFocusNode: _getFocusNode,\n        pickImage: _pickStockImage,\n        pickAndUploadImage: _pickAndUploadImage,\n      ),\n    ]"
    
    new_content_tab = new_content_tab[:b['full_match_start']] + replacement + new_content_tab[b['full_match_end']:]

imports = "import 'editor_types.dart';\n"
for b in blocks_data:
    main_type = b['types'][0]
    imports += f"import 'blocks/{main_type}_editor.dart';\n"

final_content = content[:start_idx] + new_content_tab + content[end_idx:]

import_end = final_content.rfind("import ")
next_newline = final_content.find("\n", import_end)
final_content = final_content[:next_newline+1] + imports + final_content[next_newline+1:]

with open(filepath, 'w') as f:
    f.write(final_content)

print("Main file refactored successfully.")
