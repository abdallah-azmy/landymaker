import 'dart:typed_data';

enum SelectedImageSource { local, pixabay, url }

class SelectedImageData {
  final SelectedImageSource source;
  final String? url; // For external URL or Pixabay previewURL
  final String? webformatUrl; // For Pixabay ImgBB upload
  final Uint8List? bytes; // For Local File upload

  SelectedImageData({
    required this.source,
    this.url,
    this.webformatUrl,
    this.bytes,
  });

  factory SelectedImageData.local(Uint8List bytes) {
    return SelectedImageData(
      source: SelectedImageSource.local,
      bytes: bytes,
    );
  }

  factory SelectedImageData.pixabay({
    required String previewUrl,
    required String webformatUrl,
  }) {
    return SelectedImageData(
      source: SelectedImageSource.pixabay,
      url: previewUrl,
      webformatUrl: webformatUrl,
    );
  }

  factory SelectedImageData.url(String url) {
    return SelectedImageData(
      source: SelectedImageSource.url,
      url: url,
    );
  }
}
