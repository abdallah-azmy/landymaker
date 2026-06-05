import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controllers/image_picker_cubit.dart';
import '../../controllers/image_picker_state.dart';
import '../../../../core/widgets/custom_network_image.dart';

import '../../models/selected_image_data.dart';

class ImagePickerModal extends StatelessWidget {
  const ImagePickerModal({super.key});

  /// Helper to easily show this modal and await the selected data
  static Future<SelectedImageData?> show(BuildContext context) {
    return showModalBottomSheet<SelectedImageData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ImagePickerModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImagePickerCubit(),
      child: const _ImagePickerModalContent(),
    );
  }
}

class _ImagePickerModalContent extends StatefulWidget {
  const _ImagePickerModalContent();

  @override
  State<_ImagePickerModalContent> createState() => _ImagePickerModalContentState();
}

class _ImagePickerModalContentState extends State<_ImagePickerModalContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedImageType = 'photo';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!context.read<ImagePickerCubit>().isClosed) {
        context.read<ImagePickerCubit>().searchPixabay(_searchController.text, loadMore: true);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with BlocListener to handle success and pop the modal
    return BlocListener<ImagePickerCubit, ImagePickerState>(
      listener: (context, state) {
        if (state is ImagePickerSuccess) {
          Navigator.of(context).pop(state.selectedData);
        } else if (state is ImagePickerUploadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
          );
        } else if (state is ImagePickerPixabayError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
          );
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Dynamic sizing based on screen constraints (Responsive)
          final isMobile = constraints.maxWidth < 600;
          final sheetHeight = MediaQuery.of(context).size.height * (isMobile ? 0.9 : 0.7);
          final sheetWidth = isMobile ? constraints.maxWidth : 600.0;

          return Center(
            child: Container(
              width: sheetWidth,
              height: sheetHeight,
              margin: isMobile ? EdgeInsets.zero : const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A), // Slate 900
                borderRadius: isMobile 
                    ? const BorderRadius.vertical(top: Radius.circular(20))
                    : BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E293B)), // Slate 800
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 24, spreadRadius: 4),
                ],
              ),
              child: ClipRRect(
                borderRadius: isMobile 
                    ? const BorderRadius.vertical(top: Radius.circular(20))
                    : BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _buildHeader(),
                        _buildTabBar(),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildLocalUploadTab(),
                              _buildPixabayTab(),
                              _buildUrlTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Select Media',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: const Color(0xFF00E5FF), // Cyan Accent
      labelColor: const Color(0xFF00E5FF),
      unselectedLabelColor: Colors.white54,
      tabs: const [
        Tab(icon: Icon(Icons.upload_file), text: 'Upload'),
        Tab(icon: Icon(Icons.image_search), text: 'Pixabay'),
        Tab(icon: Icon(Icons.link), text: 'URL'),
      ],
    );
  }

  Widget _buildLocalUploadTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            'Upload from your device',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<ImagePickerCubit>().pickLocalImage(),
            icon: const Icon(Icons.photo_library),
            label: const Text('Browse Files'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Max size: 5MB • Formats: JPG, PNG, WEBP\nImages will be automatically optimized.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPixabayTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search free images...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF1E293B), // Slate 800
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFF00E5FF)),
                      onPressed: () {
                        context.read<ImagePickerCubit>().searchPixabay(_searchController.text, imageType: _selectedImageType);
                      },
                    ),
                  ),
                  onSubmitted: (val) => context.read<ImagePickerCubit>().searchPixabay(val, imageType: _selectedImageType),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedImageType,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white),
                    icon: const Icon(Icons.filter_list, color: Color(0xFF00E5FF)),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'photo', child: Text('Photos')),
                      DropdownMenuItem(value: 'illustration', child: Text('Illustrations')),
                      DropdownMenuItem(value: 'vector', child: Text('Vectors')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedImageType = val);
                        context.read<ImagePickerCubit>().searchPixabay(_searchController.text, imageType: val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ImagePickerCubit, ImagePickerState>(
            buildWhen: (previous, current) => 
                current is ImagePickerLoadingPixabay || 
                current is ImagePickerPixabayLoaded || 
                current is ImagePickerPixabayError ||
                current is ImagePickerInitial,
            builder: (context, state) {
              if (state is ImagePickerLoadingPixabay) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
              } else if (state is ImagePickerPixabayLoaded) {
                if (state.images.isEmpty) {
                  return const Center(child: Text('No results found.', style: TextStyle(color: Colors.white54)));
                }
                return Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: state.images.length,
                        itemBuilder: (context, index) {
                          final image = state.images[index];
                          return GestureDetector(
                            onTap: () {
                              context.read<ImagePickerCubit>().selectPixabayImage(image.previewUrl, image.webformatUrl);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CustomNetworkImage(
                                imageUrl: image.previewUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (state.isFetchingMore)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
                      ),
                  ],
                );
            }
            if (state is ImagePickerPixabayError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              );
            }
            return const Center(
              child: Text('Search Pixabay to find free stock images.', style: TextStyle(color: Colors.white54)),
            );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUrlTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Insert Image via Direct URL',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ensure the URL points directly to an image file (e.g. .jpg, .png).',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _urlController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'https://example.com/image.jpg',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<ImagePickerCubit>().submitDirectUrl(_urlController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Insert Image', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

}
