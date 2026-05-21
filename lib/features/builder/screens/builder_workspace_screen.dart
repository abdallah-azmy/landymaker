import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../../../core/widgets/molecules/form_group.dart';
import '../../../core/widgets/molecules/status_pill.dart';
// Removed sl/AuthService imports to maintain architectural boundary
import '../controllers/builder_cubit.dart';
import '../controllers/builder_state.dart';

class BuilderWorkspaceScreen extends StatefulWidget {
  final VoidCallback onBackToDashboard;

  const BuilderWorkspaceScreen({super.key, required this.onBackToDashboard});

  @override
  State<BuilderWorkspaceScreen> createState() => _BuilderWorkspaceScreenState();
}

class _BuilderWorkspaceScreenState extends State<BuilderWorkspaceScreen> {
  int? _editingBlockIndex;

  @override
  void initState() {
    super.initState();
    context.read<LandingPageBuilderCubit>().loadForCurrentUser();
  }

  void _addBlock(LandingPageBuilderCubit cubit, String type) {
    cubit.addBlock(type);
    final currentState = cubit.state;
    if (currentState is BuilderLoaded) {
      final blocksCount = (currentState.designMap['blocks'] as List).length;
      setState(() => _editingBlockIndex = blocksCount - 1);
    }
  }

  void _deleteBlock(LandingPageBuilderCubit cubit, int index) {
    cubit.deleteBlock(index);
    setState(() => _editingBlockIndex = null);
  }

  void _moveBlock(LandingPageBuilderCubit cubit, int index, bool up) {
    cubit.moveBlock(index, up);
    setState(() => _editingBlockIndex = null);
  }

  Future<void> _pickAndUploadImage(LandingPageBuilderCubit cubit, int blockIndex) async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.image);
      if (result != null && result.files.isNotEmpty) {
        await cubit.uploadBlockImage(blockIndex, result.files.first);
      }
    } catch (_) {
      // Handled inside cubit state error message
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final builderCubit = context.watch<LandingPageBuilderCubit>();
    final state = builderCubit.state;

    if (state is BuilderLoading || state is BuilderInitial) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
      );
    }

    if (state is BuilderFailure) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Error loading builder canvas", style: AppTypography.h2),
              const SizedBox(height: 8),
              Text(state.message, style: AppTypography.bodyMedium.copyWith(color: AppColors.dangerRed)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  builderCubit.loadForCurrentUser();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final loadedState = state as BuilderLoaded;
    final List blocksList = loadedState.designMap['blocks'] as List? ?? [];
    final subdomain = loadedState.subdomain;
    final isSaving = loadedState.isSaving;
    final successMessage = loadedState.successMessage;
    final errorMessage = loadedState.errorMessage;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        title: Row(
          children: [
            IconButton(
              icon: Icon(loc.isRtl ? Icons.arrow_forward : Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: widget.onBackToDashboard,
            ),
            const SizedBox(width: 8),
            Text("Section Builder Workspace", style: AppTypography.h3),
          ],
        ),
        actions: [
          PrimaryButton(
            text: "Save & Deploy",
            icon: Icons.rocket_launch_rounded,
            onPressed: () {
              builderCubit.saveForCurrentUser();
            },
            isLoading: isSaving,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Sidebar: Block properties and order controls
          Container(
            width: 380,
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(right: BorderSide(color: AppColors.border, width: 1.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top control: Add block
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Add Page Sections", style: AppTypography.h3),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardBg),
                              onPressed: () => _addBlock(builderCubit, 'hero'),
                              child: Text("+ Hero", style: AppTypography.caption.copyWith(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardBg),
                              onPressed: () => _addBlock(builderCubit, 'features'),
                              child: Text("+ Features", style: AppTypography.caption.copyWith(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardBg),
                              onPressed: () => _addBlock(builderCubit, 'lead_form'),
                              child: Text("+ Form", style: AppTypography.caption.copyWith(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.border, height: 1.2),

                // Editor Panel: Renders lists of blocks or active editing properties
                Expanded(
                  child: SingleChildScrollView(
                    child: _editingBlockIndex != null && _editingBlockIndex! < blocksList.length
                        ? _buildBlockPropertiesEditor(loc, builderCubit, loadedState, _editingBlockIndex!)
                        : _buildBlocksOrderList(loc, builderCubit, blocksList),
                  ),
                ),
              ],
            ),
          ),

          // Main Canvas Preview Pane
          Expanded(
            child: Container(
              color: const Color(0xFF0F172A), // Slate 900
              child: Stack(
                children: [
                  // Rendering of public mockup blocks in simulated web canvas viewport
                  Center(
                    child: Container(
                      width: 1000,
                      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 36,
                          )
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // Mock Browser Header
                          Container(
                            height: 36,
                            color: const Color(0xFFE2E8F0),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Row(
                                  children: List.generate(3, (i) => Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: i == 0 ? Colors.red : (i == 1 ? Colors.orange : Colors.green),
                                    ),
                                  )),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      "https://${subdomain.isEmpty ? 'your-brand' : subdomain}.mylandy.com",
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Live rendering canvas of blocks
                          Expanded(
                            child: SingleChildScrollView(
                              child: Directionality(
                                textDirection: loc.isRtl ? TextDirection.rtl : TextDirection.ltr,
                                child: Column(
                                  children: blocksList.map((block) {
                                    return _renderMockBlockOnCanvas(block);
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Overlay Success / Error banners
                  if (successMessage != null)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.activeGreen, borderRadius: BorderRadius.circular(8)),
                        child: Text(successMessage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (errorMessage != null)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.dangerRed, borderRadius: BorderRadius.circular(8)),
                        child: Text(errorMessage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Renders the list of blocks with Order actions (Move Up / Down, Edit, Delete)
  Widget _buildBlocksOrderList(LocalizationCubit loc, LandingPageBuilderCubit cubit, List blocks) {
    if (blocks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          "No blocks added yet. Click an option at the top to insert a section.",
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Manage Block Hierarchy", style: AppTypography.h3.copyWith(fontSize: 15)),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: blocks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final block = blocks[index] as Map;
              final String type = block['type'] ?? '';
              final String title = block['title'] ?? 'Section';

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatusPill(
                            label: type.toUpperCase(),
                            color: type == 'hero'
                                ? AppColors.secondary
                                : (type == 'features' ? AppColors.primary : AppColors.accent),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Actions Row
                    IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded, size: 18, color: AppColors.textSecondary),
                      onPressed: index > 0 ? () => _moveBlock(cubit, index, true) : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward_rounded, size: 18, color: AppColors.textSecondary),
                      onPressed: index < blocks.length - 1 ? () => _moveBlock(cubit, index, false) : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.secondary),
                      onPressed: () => setState(() => _editingBlockIndex = index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_rounded, size: 18, color: AppColors.dangerRed),
                      onPressed: () => _deleteBlock(cubit, index),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Renders editing configurations panel for the selected block
  Widget _buildBlockPropertiesEditor(LocalizationCubit loc, LandingPageBuilderCubit cubit, BuilderLoaded state, int index) {
    final List blocks = state.designMap['blocks'] as List;
    final block = blocks[index] as Map<String, dynamic>;
    final String type = block['type'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Edit Section Details", style: AppTypography.h3),
              TextButton(
                onPressed: () => setState(() => _editingBlockIndex = null),
                child: Text("Done", style: AppTypography.button.copyWith(color: AppColors.secondary)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Common Fields: Title
          FormGroup(
            label: "Title Context",
            child: CustomTextField(
              controller: TextEditingController(text: block['title'] ?? '')..selection = TextSelection.collapsed(offset: (block['title'] ?? '').length),
              onChanged: (val) => cubit.updateBlockProperty(index, 'title', val),
            ),
          ),
          const SizedBox(height: 16),

          // Hero Specific Fields: Subtitle, ButtonText, ImageUrl
          if (type == 'hero') ...[
            FormGroup(
              label: "Subtitle Context",
              child: CustomTextField(
                controller: TextEditingController(text: block['subtitle'] ?? '')..selection = TextSelection.collapsed(offset: (block['subtitle'] ?? '').length),
                maxLines: 3,
                onChanged: (val) => cubit.updateBlockProperty(index, 'subtitle', val),
              ),
            ),
            const SizedBox(height: 16),
            FormGroup(
              label: "Button Label Text",
              child: CustomTextField(
                controller: TextEditingController(text: block['button_text'] ?? '')..selection = TextSelection.collapsed(offset: (block['button_text'] ?? '').length),
                onChanged: (val) => cubit.updateBlockProperty(index, 'button_text', val),
              ),
            ),
            const SizedBox(height: 16),
            FormGroup(
              label: "Hero Image Resource",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: TextEditingController(text: block['image_url'] ?? '')..selection = TextSelection.collapsed(offset: (block['image_url'] ?? '').length),
                    onChanged: (val) => cubit.updateBlockProperty(index, 'image_url', val),
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    text: loc.translate('upload_image'),
                    icon: Icons.upload_file_rounded,
                    isSecondary: true,
                    onPressed: () => _pickAndUploadImage(cubit, index),
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ],

          // Lead Form Specific Fields: ButtonText
          if (type == 'lead_form') ...[
            FormGroup(
              label: "Submit Button Text",
              child: CustomTextField(
                controller: TextEditingController(text: block['button_text'] ?? '')..selection = TextSelection.collapsed(offset: (block['button_text'] ?? '').length),
                onChanged: (val) => cubit.updateBlockProperty(index, 'button_text', val),
              ),
            ),
          ],

          // Features Specific Fields: editing list of feature items
          if (type == 'features') ...[
            const SizedBox(height: 12),
            Text("Feature Items list", style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...List.generate((block['items'] as List).length, (fIndex) {
              final item = (block['items'] as List)[fIndex] as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBgHover,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    CustomTextField(
                      hintText: "Item Title",
                      controller: TextEditingController(text: item['title'] ?? '')..selection = TextSelection.collapsed(offset: (item['title'] ?? '').length),
                      onChanged: (val) => cubit.updateFeatureItem(index, fIndex, 'title', val),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: "Item Description",
                      controller: TextEditingController(text: item['description'] ?? '')..selection = TextSelection.collapsed(offset: (item['description'] ?? '').length),
                      maxLines: 2,
                      onChanged: (val) => cubit.updateFeatureItem(index, fIndex, 'description', val),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // Renders the mockup section blocks inside the simulated HTML Canvas
  Widget _renderMockBlockOnCanvas(Map<dynamic, dynamic> block) {
    final String type = block['type'] ?? '';
    final String title = block['title'] ?? '';

    if (type == 'hero') {
      final String subtitle = block['subtitle'] ?? '';
      final String btnText = block['button_text'] ?? '';
      final String imageUrl = block['image_url'] ?? '';

      return Container(
        color: const Color(0xFFF8FAFC), // Off-white clean layout
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 36),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(btnText, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            if (imageUrl.isNotEmpty) ...[
              const SizedBox(width: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 240,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 240,
                    height: 180,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (type == 'features') {
      final List items = block['items'] as List? ?? [];

      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 36),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                final String itemTitle = item['title'] ?? '';
                final String itemDesc = item['description'] ?? '';

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 24),
                        const SizedBox(height: 12),
                        Text(itemTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                        const SizedBox(height: 8),
                        Text(itemDesc, style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    if (type == 'lead_form') {
      final String btnText = block['button_text'] ?? '';

      return Container(
        color: const Color(0xFFF1F5F9), // Light Slate grey
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 36),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 380,
              child: Column(
                children: [
                  Container(
                    height: 36,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Text("Email Address", style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(btnText, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }
}
