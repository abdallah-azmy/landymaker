import os
import glob

blocks_dir = 'lib/features/builder/widgets/editors/blocks'

correct_imports = """import 'package:flutter/material.dart';
import '../../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/atoms/primary_button.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import 'package:flutter/services.dart';
import '../../../../../core/utils/toast_service.dart';
"""

for filepath in glob.glob(os.path.join(blocks_dir, '*.dart')):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # The class declaration starts with `class `
    class_idx = content.find('class ')
    if class_idx != -1:
        new_content = correct_imports + '\n' + content[class_idx:]
        with open(filepath, 'w') as f:
            f.write(new_content)

print("Imports fixed.")
