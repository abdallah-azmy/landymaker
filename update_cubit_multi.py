import re
import uuid

filepath = 'lib/features/builder/controllers/builder_cubit.dart'

with open(filepath, 'r') as f:
    content = f.read()

search_pattern = "} else if (type == 'video_embed') {"
multi_step_code = """} else if (type == 'multi_step_lead_form') {
      blocks.add({
        'type': 'multi_step_lead_form',
        'schema_version': 1,
        'title': 'طلب تسعير',
        'subtitle': 'أجب على الأسئلة للحصول على عرض سعر دقيق',
        'success_message': 'تم الإرسال بنجاح!',
        'enable_local_save': true,
        'steps': [
          {
            'step_id': const Uuid().v4(),
            'step_title': 'البيانات الأساسية',
            'fields': [
              {
                'field_id': const Uuid().v4(),
                'field_type': 'text',
                'label': 'الاسم الكامل',
                'placeholder': 'أدخل اسمك ثلاثياً',
                'is_required': true,
                'validation': {'min_length': 3},
              },
              {
                'field_id': const Uuid().v4(),
                'field_type': 'radio',
                'label': 'نوع الحساب',
                'options': [
                  {'value': 'individual', 'label': 'فرد'},
                  {'value': 'business', 'label': 'شركة'},
                ],
                'is_required': true,
              }
            ]
          },
          {
            'step_id': const Uuid().v4(),
            'step_title': 'معلومات الاتصال',
            'fields': [
              {
                'field_id': const Uuid().v4(),
                'field_type': 'phone',
                'label': 'رقم الهاتف',
                'placeholder': '+201xxxxxxxxx',
                'is_required': true,
              }
            ]
          }
        ],
      });
    """

idx = content.find(search_pattern)
if idx != -1:
    content = content[:idx] + multi_step_code + content[idx:]
    with open(filepath, 'w') as f:
        f.write(content)
    print("Updated builder_cubit.dart")
else:
    print("Could not find pattern in builder_cubit.dart")
