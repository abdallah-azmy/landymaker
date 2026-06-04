import re

filepath = 'lib/features/builder/widgets/editors/block_properties_editor.dart'

with open(filepath, 'r') as f:
    content = f.read()

import_statement = "import 'blocks/multi_step_form_editor.dart';\n"
last_import_idx = content.rfind("import '")
next_newline_idx = content.find('\n', last_import_idx)

content = content[:next_newline_idx+1] + import_statement + content[next_newline_idx+1:]

router_pattern = "List<Widget> _buildContentTab(LandingPageBuilderCubit cubit, Map<String, dynamic> block, String type) {"
router_idx = content.find(router_pattern)

array_start_idx = content.find("return [", router_idx)

multi_step_code = """
      if (type == 'multi_step_lead_form') ...[
      MultiStepFormEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
      ),
    ],"""

content = content[:array_start_idx + 8] + multi_step_code + content[array_start_idx + 8:]

title_pattern = "case 'video_embed':"
title_code = """case 'multi_step_lead_form':
        sectionName = "نموذج خطوات (Multi-Step Form)";
        break;
      """

idx2 = content.find(title_pattern)
if idx2 != -1:
    content = content[:idx2] + title_code + content[idx2:]

with open(filepath, 'w') as f:
    f.write(content)

print("Updated block_properties_editor.dart")
