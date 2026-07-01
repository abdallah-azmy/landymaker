import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/core/widgets/draggable_modal_sheet.dart';
import '../../controllers/image_picker_cubit.dart';
import '../../controllers/image_picker_state.dart';
import '../../../../core/widgets/custom_network_image.dart';
import '../../../../core/widgets/atoms/cube_progress.dart';

import '../../models/selected_image_data.dart';

class ImagePickerModal extends StatelessWidget {
  const ImagePickerModal({super.key});

  /// Helper to easily show this modal and await the selected data
  static Future<SelectedImageData?> show(BuildContext context) {
    return DraggableModalSheet.show<SelectedImageData>(
      context: context,
      title: "اختيار صورة",
      initialChildSize: 0.8,
      child: const ImagePickerModal(),
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
  State<_ImagePickerModalContent> createState() =>
      _ImagePickerModalContentState();
}

class _ImagePickerModalContentState extends State<_ImagePickerModalContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedImageType = 'photo';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);

    // Refresh gallery if user clicks on that tab
    _tabController.addListener(() {
      if (_tabController.index == 1) { // Gallery tab
        context.read<ImagePickerCubit>().loadUserGallery();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!context.read<ImagePickerCubit>().isClosed) {
        context.read<ImagePickerCubit>().searchPixabay(
          _searchController.text,
          loadMore: true,
        );
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
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (state is ImagePickerPixabayError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLocalUploadTab(),
                _buildUserGalleryTab(),
                _buildPixabayTab(),
                _buildUrlTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Theme.of(context).colorScheme.primary,
      labelColor: Theme.of(context).colorScheme.primary,
      unselectedLabelColor: Colors.white54,
      tabs: const [
        Tab(icon: Icon(Icons.upload_file), text: 'Upload'),
        Tab(icon: Icon(Icons.collections_rounded), text: 'My Gallery'),
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
          Icon(
            Icons.cloud_upload_outlined,
            size: 64,
            color: Colors.white24,
          ),
          SizedBox(height: 16),
          const Text(
            'Upload from your device',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<ImagePickerCubit>().pickLocalImage(),
            icon: Icon(Icons.photo_library),
            label: const Text('Browse Files'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 16),
          const Text(
            'Max size: 5MB • Formats: JPG, PNG, WEBP\nImages will be automatically optimized.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildUserGalleryTab() {
    return BlocBuilder<ImagePickerCubit, ImagePickerState>(
      buildWhen: (previous, current) =>
          current is ImagePickerLoadingGallery ||
          current is ImagePickerGalleryLoaded ||
          current is ImagePickerGalleryError,
      builder: (context, state) {
        if (state is ImagePickerLoadingGallery) {
          return Center(
            child: CubeProgress(color: Theme.of(context).colorScheme.primary),
          );
        }

        if (state is ImagePickerGalleryLoaded) {
          final images = state.images;
          if (images.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported_outlined,
                      size: 48, color: Colors.white24),
                  SizedBox(height: 16),
                  const Text('No uploaded images yet.',
                      style: TextStyle(color: Colors.white54)),
                  SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () => _tabController.animateTo(0),
                    icon:
                        Icon(Icons.upload_file, color: Theme.of(context).colorScheme.primary),
                    label: Text('Go to Upload',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final img = images[index];
              return GestureDetector(
                onTap: () => context
                    .read<ImagePickerCubit>()
                    .selectGalleryImage(img['url']),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CustomNetworkImage(
                      imageUrl: img['url'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        }

        if (state is ImagePickerGalleryError) {
          return Center(
              child: Text(state.message,
                  style: TextStyle(color: Colors.redAccent)));
        }

        return const Center(
          child: Text('Loading your gallery...',
              style: TextStyle(color: Colors.white54)),
        );
      },
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
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search free images...',
                    hintStyle: TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                      onPressed: () {
                        context.read<ImagePickerCubit>().searchPixabay(
                          _searchController.text,
                          imageType: _selectedImageType,
                        );
                      },
                    ),
                  ),
                  onSubmitted: (val) => context
                      .read<ImagePickerCubit>()
                      .searchPixabay(val, imageType: _selectedImageType),
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedImageType,
                    dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    style: TextStyle(color: Colors.white),
                    icon: Icon(
                      Icons.filter_list,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'photo', child: Text('Photos')),
                      DropdownMenuItem(
                        value: 'illustration',
                        child: Text('Illustrations'),
                      ),
                      DropdownMenuItem(value: 'vector', child: Text('Vectors')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedImageType = val);
                        context.read<ImagePickerCubit>().searchPixabay(
                          _searchController.text,
                          imageType: val,
                        );
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
                return Center(
                  child: CubeProgress(color: Theme.of(context).colorScheme.primary),
                );
              } else if (state is ImagePickerPixabayLoaded) {
                if (state.images.isEmpty) {
                  return const Center(
                    child: Text(
                      'No results found.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: state.images.length,
                        itemBuilder: (context, index) {
                          final image = state.images[index];
                          return GestureDetector(
                            onTap: () {
                              context
                                  .read<ImagePickerCubit>()
                                  .selectPixabayImage(
                                    image.previewUrl,
                                    image.webformatUrl,
                                  );
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
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CubeProgress(
                          color: Theme.of(context).colorScheme.primary,
                        ),
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
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                );
              }
              return const Center(
                child: Text(
                  'Search Pixabay to find free stock images.',
                  style: TextStyle(color: Colors.white54),
                ),
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
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          const Text(
            'Ensure the URL points directly to an image file (e.g. .jpg, .png).',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          SizedBox(height: 24),
          TextField(
            controller: _urlController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'https://example.com/image.jpg',
              hintStyle: TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<ImagePickerCubit>().submitDirectUrl(
                  _urlController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Insert Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
