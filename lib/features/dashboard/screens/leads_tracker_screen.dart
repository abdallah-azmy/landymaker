import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/organisms/responsive_data_table.dart';
import '../../../core/widgets/molecules/page_context_banner.dart';
// Removed sl/AuthService imports to maintain architectural boundary
import '../controllers/leads_analytics_cubit.dart';
import '../controllers/leads_analytics_state.dart';
import '../controllers/landing_pages_cubit.dart';
import '../controllers/landing_pages_state.dart';
import '../widgets/empty_workspace_state.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'dart:html' as html;
import '../../../core/utils/toast_service.dart';

class LeadsTrackerScreen extends StatefulWidget {
  const LeadsTrackerScreen({super.key});

  @override
  State<LeadsTrackerScreen> createState() => _LeadsTrackerScreenState();
}

class _LeadsTrackerScreenState extends State<LeadsTrackerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LeadsAnalyticsCubit>().fetchStatsForCurrentUser();
  }

  String _normalizePhoneNumber(String phone) {
    String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }
    return digits;
  }

  Future<void> _exportToCsv(List<Map<String, dynamic>> leads) async {
    try {
      final StringBuffer csv = StringBuffer();
      final loc = context.read<LocalizationCubit>();
      
      // Headers
      csv.writeln("Visitor Name,Visitor Email,Visitor Message,Phone Number,Submitted Date");
      
      // Rows
      for (final lead in leads) {
        final formData = lead['form_data'] is Map ? lead['form_data'] : {};
        final name = (formData['name'] ?? '').toString().replaceAll('"', '""');
        final email = (formData['email'] ?? '').toString().replaceAll('"', '""');
        final message = (formData['message'] ?? '').toString().replaceAll('"', '""');
        
        final phoneKey = formData.keys.firstWhere(
          (k) {
            final lk = k.toString().toLowerCase();
            return lk.contains('phone') || lk.contains('mobile') || lk.contains('هاتف') || lk.contains('جوال') || lk.contains('تلفون');
          },
          orElse: () => '',
        );
        final phone = phoneKey.isNotEmpty ? (formData[phoneKey] ?? '').toString().replaceAll('"', '""') : '';

        final String rawDate = lead['created_at'] ?? '';
        String formattedDate = '';
        if (rawDate.isNotEmpty) {
          try {
            final parsed = DateTime.parse(rawDate).toLocal();
            formattedDate = "${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')} ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
          } catch (_) {
            formattedDate = rawDate;
          }
        }
        
        csv.writeln('"$name","$email","$message","$phone","$formattedDate"');
      }

      // Convert to UTF-8 bytes and prepend BOM (\uFEFF)
      final bytes = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(csv.toString())]);

      await FileSaver.instance.saveFile(
        name: 'leads_export_${DateTime.now().millisecondsSinceEpoch}',
        bytes: bytes,
        ext: 'csv',
        mimeType: MimeType.csv,
      );

      if (mounted) {
        ToastService.showSuccess(
          context,
          message: loc.translate('export_success'),
        );
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          context,
          message: context.read<LocalizationCubit>().translate('export_error'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final cubit = context.watch<LeadsAnalyticsCubit>();
    final state = cubit.state;

    final pagesState = context.watch<LandingPagesCubit>().state;
    if (pagesState is LandingPagesLoaded && pagesState.pages.isEmpty) {
      return const EmptyWorkspaceState();
    }

    if (state is LeadsAnalyticsLoading || state is LeadsAnalyticsInitial) {
      return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }

    if (state is LeadsAnalyticsFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Failed to load leads list", style: AppTypography.h2),
            SizedBox(height: 8),
            Text(state.message, style: AppTypography.bodyMedium.copyWith(color: AppColors.dangerRed)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                cubit.fetchStatsForCurrentUser();
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    final loadedState = state as LeadsAnalyticsLoaded;
    final List<Map<String, dynamic>> leadsList = loadedState.leads;
    final String? errorMessage = loadedState.errorMessage;

    // Columns headers
    final headers = [
      loc.translate('visitor_name'),
      loc.translate('visitor_email'),
      loc.translate('visitor_message'),
      "Submitted Date",
      loc.translate('whatsapp'),
    ];

    // Rows preparation
    final rows = leadsList.map((lead) {
      final formData = lead['form_data'] is Map 
          ? lead['form_data'] 
          : {};
      final String name = formData['name'] ?? '';
      final String email = formData['email'] ?? '';
      final String message = formData['message'] ?? '';
      
      final phoneKey = formData.keys.firstWhere(
        (k) {
          final lk = k.toString().toLowerCase();
          return lk.contains('phone') || lk.contains('mobile') || lk.contains('هاتف') || lk.contains('جوال') || lk.contains('تلفون');
        },
        orElse: () => '',
      );
      final String phone = phoneKey.isNotEmpty ? formData[phoneKey]?.toString() ?? '' : '';

      // Format timestamp
      final String rawDate = lead['created_at'] ?? '';
      String formattedDate = '';
      if (rawDate.isNotEmpty) {
        try {
          final parsed = DateTime.parse(rawDate).toLocal();
          formattedDate = "${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')} ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
        } catch (_) {
          formattedDate = rawDate;
        }
      }

      return [
        Flexible(child: Text(name, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
        Flexible(child: Text(email, style: AppTypography.bodyMedium, overflow: TextOverflow.ellipsis)),
        Flexible(child: Text(message, style: AppTypography.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis)),
        Text(formattedDate, style: AppTypography.caption),
        phone.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366)),
                tooltip: loc.translate('chat_on_whatsapp'),
                onPressed: () {
                  final cleanNumber = _normalizePhoneNumber(phone);
                  final encodedMsg = Uri.encodeComponent(
                    loc.translate('whatsapp_lead_message')
                  );
                  final url = 'https://wa.me/$cleanNumber?text=$encodedMsg';
                  html.window.open(url, '_blank');
                },
              )
            : Icon(Icons.phone_disabled_rounded, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
      ];
    }).toList();

    return Padding(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate('leads'),
                    style: AppTypography.h1.copyWith(fontSize: 28),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Track visitor signups captured from your public landing pages.",
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
              Row(
                children: [
                  if (leadsList.isNotEmpty) ...[
                    ElevatedButton.icon(
                      onPressed: () => _exportToCsv(leadsList),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      icon: Icon(Icons.download_rounded, size: 18),
                      label: Text(loc.translate('export_csv')),
                    ),
                    SizedBox(width: 12),
                  ],
                  IconButton(
                    onPressed: () {
                      cubit.fetchStatsForCurrentUser();
                    },
                    icon: Icon(Icons.refresh_rounded, color: AppColors.secondary),
                    tooltip: "Reload Leads List",
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          const PageContextBanner(
            title: "إدارة العملاء المحتملين",
            description: "هنا يمكنك استعراض قائمة العملاء الذين قاموا بالتسجيل أو ترك بياناتهم عبر صفحة الهبوط المحددة حالياً.",
            icon: Icons.contacts_rounded,
          ),
          SizedBox(height: 16),

          if (errorMessage != null) ...[
            Text(errorMessage, style: AppTypography.bodyMedium.copyWith(color: AppColors.dangerRed)),
            SizedBox(height: 16),
          ],

          Expanded(
            child: ResponsiveDataTable(
              title: "العملاء المحتملين",
              headers: headers,
              rows: rows,
              emptyMessage: loc.translate('no_data'),
              onSearch: (_) {},
              onSort: (_) {},
              onPageChanged: (_) {},
            ),
          ),
        ],
      ),
    );
  }
}
