import re

filepath = 'lib/features/builder/controllers/builder_cubit.dart'

with open(filepath, 'r') as f:
    content = f.read()

search_pattern = "} else if (type == 'trust_logos') {"
video_embed_code = """} else if (type == 'video_embed') {
      blocks.add({
        'type': 'video_embed',
        'title': 'شاهد كيف نعمل',
        'subtitle': 'فيديو تعريفي قصير يوضح مزايا المنصة.',
        'video_url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'aspect_ratio': '16:9',
        'max_width': 900,
        'use_thumbnail': true,
        'autoplay': false,
        'show_controls': true,
      });
    """

idx = content.find(search_pattern)
if idx != -1:
    content = content[:idx] + video_embed_code + content[idx:]
    with open(filepath, 'w') as f:
        f.write(content)
    print("Updated builder_cubit.dart")
else:
    print("Could not find pattern")
