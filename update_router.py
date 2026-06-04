import re

filepath = 'lib/features/builder/widgets/editors/block_properties_editor.dart'

with open(filepath, 'r') as f:
    content = f.read()

import_statement = "import 'blocks/video_embed_editor.dart';\n"
last_import_idx = content.rfind("import '")
next_newline_idx = content.find('\n', last_import_idx)

content = content[:next_newline_idx+1] + import_statement + content[next_newline_idx+1:]

router_pattern = "List<Widget> _buildContentTab(LandingPageBuilderCubit cubit, Map<String, dynamic> block, String type) {"
router_idx = content.find(router_pattern)

array_start_idx = content.find("return [", router_idx)

video_embed_code = """
      if (type == 'video_embed') ...[
      VideoEmbedEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
      ),
    ],"""

content = content[:array_start_idx + 8] + video_embed_code + content[array_start_idx + 8:]

with open(filepath, 'w') as f:
    f.write(content)

print("Updated block_properties_editor.dart")
