import 'package:flutter/material.dart';
import '../../controllers/builder_cubit.dart';
import 'editor_types.dart';
import 'blocks/hero_editor.dart';
import 'blocks/features_editor.dart';
import 'blocks/logo_header_editor.dart';
import 'blocks/lead_form_editor.dart';
import 'blocks/location_map_editor.dart';
import 'blocks/pricing_editor.dart';
import 'blocks/faq_editor.dart';
import 'blocks/products_editor.dart';
import 'blocks/testimonials_editor.dart';
import 'blocks/contact_info_editor.dart';
import 'blocks/social_qr_editor.dart';
import 'blocks/qr_code_editor.dart';
import 'blocks/basic_section_editor.dart';
import 'blocks/gallery_editor.dart';
import 'blocks/trust_logos_editor.dart';
import 'blocks/animated_counter_editor.dart';
import 'blocks/video_embed_editor.dart';
import 'blocks/multi_step_form_editor.dart';
import 'blocks/working_hours_editor.dart';
import 'blocks/statistics_grid_editor.dart';
import 'blocks/team_members_editor.dart';
import 'blocks/service_steps_editor.dart';
import 'blocks/cta_banner_editor.dart';
import 'blocks/comparison_table_editor.dart';
import 'blocks/featured_product_editor.dart';
import 'blocks/bento_store_editor.dart';

Widget? buildContentEditor({
  required String type,
  required LandingPageBuilderCubit cubit,
  required Map<String, dynamic> block,
  required int index,
  required GetController getController,
  required GetFocusNode getFocusNode,
  required PickImage pickImage,
  required PickAndUploadImage pickAndUploadImage,
  required PersistAsset persistAsset,
}) {
  switch (type) {
    case 'hero':
    case 'hero_saas':
      return HeroEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, pickAndUploadImage: pickAndUploadImage,
        persistAsset: persistAsset,
      );
    case 'logo_header':
      return LogoHeaderEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, pickAndUploadImage: pickAndUploadImage,
        persistAsset: persistAsset,
      );
    case 'multi_step_lead_form':
      return MultiStepFormEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
      );
    case 'video_embed':
      return VideoEmbedEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
      );
    case 'pricing':
      return PricingEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
      );
    case 'faq':
      return FaqEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, pickAndUploadImage: pickAndUploadImage,
      );
    case 'testimonials':
      return TestimonialsEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, persistAsset: persistAsset,
      );
    case 'gallery':
      return GalleryEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, pickAndUploadImage: pickAndUploadImage,
        persistAsset: persistAsset,
      );
    case 'lead_form':
    case 'lead_magnet':
      return LeadFormEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, pickAndUploadImage: pickAndUploadImage,
        persistAsset: persistAsset,
      );
    case 'contact_info':
      return ContactInfoEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, pickAndUploadImage: pickAndUploadImage,
      );
    case 'location_map':
      return LocationMapEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, pickAndUploadImage: pickAndUploadImage,
      );
    case 'social_qr':
      return SocialQrEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, pickAndUploadImage: pickAndUploadImage,
      );
    case 'qr_code':
      return QrCodeEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, pickAndUploadImage: pickAndUploadImage,
      );
    case 'basic_section':
      return BasicSectionEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, pickAndUploadImage: pickAndUploadImage,
        persistAsset: persistAsset,
      );
    case 'trust_logos':
      return TrustLogosEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, pickAndUploadImage: pickAndUploadImage,
        persistAsset: persistAsset,
      );
    case 'animated_counter':
      return AnimatedCounterEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, pickAndUploadImage: pickAndUploadImage,
      );
    case 'working_hours':
      return WorkingHoursEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, pickAndUploadImage: pickAndUploadImage,
      );
    case 'statistics_grid':
      return StatisticsGridEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
      );
    case 'team_members':
      return TeamMembersEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, persistAsset: persistAsset,
      );
    case 'service_steps':
      return ServiceStepsEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
      );
    case 'cta_banner':
      return CtaBannerEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
      );
    case 'products':
      return ProductsEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, pickAndUploadImage: pickAndUploadImage,
        persistAsset: persistAsset,
      );
    case 'comparison_table':
      return ComparisonTableEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
      );
    case 'featured_product':
      return FeaturedProductEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, persistAsset: persistAsset,
      );
    case 'bento_store':
      return BentoStoreEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
        pickImage: pickImage, persistAsset: persistAsset,
      );
    case 'features':
      return FeaturesEditor(
        cubit: cubit, block: block, index: index,
        getController: getController, getFocusNode: getFocusNode,
      );
    default:
      return null;
  }
}
