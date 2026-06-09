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
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomSocialQrWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Map<String, dynamic>> links;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomSocialQrWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.links,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
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

    final secondaryColor = widget.theme?.secondary ?? AppColors.secondary;
    final textColor = widget.theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = widget.theme?.textSecondary ?? AppColors.textSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double verticalPadding = isMobile ? 40 : 80;

        return SectionBackground(
          bgImageUrl: widget.bgImageUrl,
          bgOverlayColor: widget.bgOverlayColor,
          bgOverlayOpacity: widget.bgOverlayOpacity,
          bgBlur: widget.bgBlur,
          theme: widget.theme,
          padding: EdgeInsetsDirectional.symmetric(vertical: verticalPadding, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                children: [
                  Text(widget.title, style: AppTypography.h2.copyWith(fontSize: isMobile ? 24 : 32, color: textColor), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(widget.subtitle, style: AppTypography.bodyMedium.copyWith(color: subTextColor, fontSize: isMobile ? 12 : 14), textAlign: TextAlign.center),
                  SizedBox(height: isMobile ? 32 : 64),
                  
                  Wrap(
                    spacing: isMobile ? 24 : 40,
                    runSpacing: isMobile ? 24 : 40,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // QR Card
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isMobile ? 16 : 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(isMobile ? 20 : 32),
                              boxShadow: [
                                BoxShadow(
                                  color: secondaryColor.withValues(alpha: 0.2),
                                  blurRadius: 40,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: RepaintBoundary(
                              key: _qrKey,
                              child: SizedBox(
                                width: isMobile ? 150 : 200,
                                height: isMobile ? 150 : 200,
                                child: PrettyQrView.data(
                                  data: liveUrl,
                                  decoration: const PrettyQrDecoration(
                                    shape: PrettyQrSmoothSymbol(
                                      color: Colors.black87, // Fixed dark color for standard scannability
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 16 : 32),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildActionButton(
                                icon: Icons.download_rounded,
                                label: "تحميل QR",
                                onTap: () => _downloadQrCode('landymaker_qr_${subdomain ?? 'page'}'),
                                textColor: textColor,
                                subTextColor: subTextColor,
                                isMobile: isMobile,
                              ),
                              const SizedBox(width: 8),
                              _buildActionButton(
                                icon: Icons.copy_rounded,
                                label: "نسخ الرابط",
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: liveUrl));
                                  ToastService.showSuccess(context, message: "تم نسخ الرابط");
                                },
                                textColor: textColor,
                                subTextColor: subTextColor,
                                isMobile: isMobile,
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Links List
                      Container(
                        width: isMobile ? double.infinity : 320,
                        child: Column(
                          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                          children: [
                            Text(
                              "روابط سريعة", 
                              style: AppTypography.h3.copyWith(
                                color: secondaryColor,
                                fontSize: isMobile ? 18 : 22,
                              )
                            ),
                            const SizedBox(height: 16),
                            ...widget.links.map((link) => _buildSocialLink(link, textColor, subTextColor, isMobile)),
                            const SizedBox(height: 8),
                            // Direct Page Link
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: subTextColor.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: secondaryColor.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.link_rounded, color: secondaryColor, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      liveUrl.replaceFirst('https://', ''),
                                      style: AppTypography.caption.copyWith(color: textColor, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 12),
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
      },
    );
  }

  Widget _buildSocialLink(Map<String, dynamic> link, Color textColor, Color subTextColor, bool isMobile) {
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
        color = textColor;
        break;
      default:
        iconData = Icons.language_rounded;
        color = AppColors.secondary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(url)),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 14),
          decoration: BoxDecoration(
            color: subTextColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: subTextColor.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(iconData, color: color, size: isMobile ? 18 : 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  platform.toUpperCase(),
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: textColor, fontSize: isMobile ? 13 : 14),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: subTextColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap, required Color textColor, required Color subTextColor, required bool isMobile}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: isMobile ? 14 : 18),
      label: Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: subTextColor.withValues(alpha: 0.1),
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: subTextColor.withValues(alpha: 0.1))),
        elevation: 0,
      ),
    );
  }
}
