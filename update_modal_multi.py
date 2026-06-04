import re

filepath = 'lib/features/builder/widgets/modals/section_library_modal.dart'

with open(filepath, 'r') as f:
    content = f.read()

search_pattern = "    {'type': 'lead_form',"
multi_step_str = "    {'type': 'multi_step_lead_form', 'name': 'نموذج متعدد الخطوات', 'icon': Icons.dynamic_form_rounded, 'category': 'basic', 'desc': 'جمع بيانات العملاء باحترافية على مراحل.', 'popular': true},\n"

idx = content.find(search_pattern)
if idx != -1:
    content = content[:idx] + multi_step_str + content[idx:]
    with open(filepath, 'w') as f:
        f.write(content)
    print("Updated section_library_modal.dart")
else:
    print("Could not find pattern in modal")
