import re

filepath = 'lib/features/builder/widgets/editors/block_properties_editor.dart'

with open(filepath, 'r') as f:
    content = f.read()

search_pattern = "case 'gallery':"
video_embed_code = """case 'video_embed':
        sectionName = "فيديو مضمن (Video Embed)";
        break;
      """

idx = content.find(search_pattern)
if idx != -1:
    content = content[:idx] + video_embed_code + content[idx:]
    with open(filepath, 'w') as f:
        f.write(content)
    print("Updated block_properties_editor.dart title generator")
else:
    print("Could not find pattern")
