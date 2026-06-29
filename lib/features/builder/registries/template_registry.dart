/// Template Registry — barrel re-export file.
///
/// All template metadata, design data, and theme palettes are split across
/// themed sub-files for AI readability and to prevent merge conflicts.
/// Do NOT add template data here — add to the appropriate theme file.
///
/// **Theme files**:
/// - `template_registry_saas.dart` — SaaS, tech, agency, digital products
/// - `template_registry_ecommerce.dart` — E-commerce, stores
/// - `template_registry_services.dart` — Services, local business, healthcare
///
/// **Public API** (in `template_registry_base.dart`):
/// - `TemplateMetadata` — data class for template info
/// - `TemplateRegistry.availableTemplates` — full list
/// - `TemplateRegistry.getTemplateDesign()` — initial design JSON
/// - `TemplateRegistry.getTemplateTheme()` — recommended theme palette
export 'template_registry_base.dart';
