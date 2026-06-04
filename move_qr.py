import re

filepath = 'lib/features/builder/widgets/editors/block_properties_editor.dart'
destpath = 'lib/features/builder/widgets/editors/blocks/products_editor.dart'

with open(filepath, 'r') as f:
    content = f.read()

start_idx = content.find('void _showProductQrShare(')
if start_idx != -1:
    # use brace matching to find end
    count = 0
    end_idx = -1
    for i in range(start_idx, len(content)):
        if content[i] == '{':
            count += 1
        elif content[i] == '}':
            count -= 1
            if count == 0:
                end_idx = i + 1
                break
    
    if end_idx != -1:
        method_str = content[start_idx:end_idx]
        
        # remove from source
        new_content = content[:start_idx] + content[end_idx:]
        with open(filepath, 'w') as f:
            f.write(new_content)
        
        # add to destination at the bottom, outside the class, or inside it. 
        # Inside the class is better, or just outside as a helper.
        with open(destpath, 'r') as f:
            dest_content = f.read()
        
        # We need `PrettyQrView` and `PrettyQrDecoration` etc. 
        # So we add the imports.
        import_str = "import 'package:pretty_qr_code/pretty_qr_code.dart';\n"
        
        # find the last brace of the class
        last_brace = dest_content.rfind('}')
        if last_brace != -1:
            dest_content = import_str + dest_content[:last_brace] + "\n\n  " + method_str.replace('\n', '\n  ') + "\n}\n"
            with open(destpath, 'w') as f:
                f.write(dest_content)
        
        print("Moved _showProductQrShare")
