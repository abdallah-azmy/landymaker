import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_saver/file_saver.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/toast_service.dart';
import '../../../services/tenant_routing_service.dart';

class CustomSocialQrWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Map<String, dynamic>> links;

  const CustomSocialQrWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.links,
  });

  @override
  State<CustomSocialQrWidget> createState() => _CustomSocialQrWidgetState();
}

class _CustomSocialQrWidgetState extends State<CustomSocialQrWidget> {
  final GlobalKey _qrKey = GlobalKey();

  Future<void> _downloadQrCode(String fileName) async {
    try {
      RenderRepaintBoundary? boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List bytes = byteData.buffer.asUint8List();

      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          ext: 'png',
          mimeType: MimeType.png,
        );
      } else {
        if (await Permission.photos.request().isGranted) {
          final result = await ImageGallerySaverPlus.saveImage(bytes, name: fileName);
          if (result['isSuccess']) {
            ToastService.showSuccess(context, message: "تم حفظ الصورة في المعرض");
          }
        }
      }
    } catch (e) {
      ToastService.showError(context, message: "فشل تحميل الصورة");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? subdomain = TenantRoutingService.getTenantIdentifier();
    final String baseUrl = Uri.base.origin;
    final String liveUrl = subdomain != null ? '$baseUrl/$subdomain' : baseUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.05)),
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Text(widget.title, style: AppTypography.h2.copyWith(fontSize: 32), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(widget.subtitle, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 64),
              
              Wrap(
                spacing: 40,
                runSpacing: 40,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // QR Card
                  Column(
                    children: [
                      RepaintBoundary(
                        key: _qrKey,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(alpha: 0.2),
                                blurRadius: 40,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: PrettyQrView.data(
                              data: liveUrl,
                              decoration: const PrettyQrDecoration(
                                shape: PrettyQrSmoothSymbol(
                                  color: AppColors.background,
                                ),
                                image: PrettyQrDecorationImage(
                                  image: AssetImage('assets/logo.png'),
                                  position: PrettyQrDecorationImagePosition.embedded,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            icon: Icons.download_rounded,
                            label: "تحميل QR",
                            onTap: () => _downloadQrCode('mylandy_qr_${subdomain ?? 'page'}'),
                          ),
                          const SizedBox(width: 12),
                          _buildActionButton(
                            icon: Icons.copy_rounded,
                            label: "نسخ الرابط",
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: liveUrl));
                              ToastService.showSuccess(context, message: "تم نسخ الرابط");
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Links List
                  Container(
                    width: 320,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("روابط سريعة", style: AppTypography.h3.copyWith(color: AppColors.secondary)),
                        const SizedBox(height: 24),
                        ...widget.links.map((link) => _buildSocialLink(link)),
                        const SizedBox(height: 16),
                        // Direct Page Link
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.link_rounded, color: AppColors.secondary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  liveUrl.replaceFirst('https://', ''),
                                  style: AppTypography.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
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
  }

  Widget _buildSocialLink(Map<String, dynamic> link) {
    final String platform = link['platform'] ?? 'website';
    final String url = link['url'] ?? '';
    
    IconData iconData;
    Color color;

    switch (platform.toLowerCase()) {
      case 'instagram':
        iconData = Icons.camera_alt_outlined;
        color = const Color(0xFFE4405F);
        break;
      case 'facebook':
        iconData = Icons.facebook_rounded;
        color = const Color(0xFF1877F2);
        break;
      case 'whatsapp':
        iconData = Icons.chat_bubble_outline_rounded;
        color = const Color(0xFF25D366);
        break;
      case 'tiktok':
        iconData = Icons.music_note_rounded;
        color = const Color(0xFF000000);
        break;
      default:
        iconData = Icons.language_rounded;
        color = AppColors.secondary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(url)),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(iconData, color: color, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  platform.toUpperCase(),
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cardBg,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
        elevation: 0,
      ),
    );
  }
}
