import re

filepath = 'lib/features/builder/widgets/modals/section_library_modal.dart'

with open(filepath, 'r') as f:
    content = f.read()

# Add to the basic category, maybe near gallery
search_pattern = "    {'type': 'gallery',"
replace_str = "    {'type': 'video_embed', 'name': 'فيديو (Video)', 'icon': Icons.video_library_rounded, 'category': 'basic', 'desc': 'تضمين فيديو يوتيوب أو فيميو.'},\n"

idx = content.find(search_pattern)
if idx != -1:
    content = content[:idx] + replace_str + content[idx:]
    with open(filepath, 'w') as f:
        f.write(content)
    print("Updated section_library_modal.dart")
else:
    print("Could not find gallery pattern in modal")
