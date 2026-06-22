import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/core/responsive/responsive_layout.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../../../services/database_service.dart';
import '../../../injection_container.dart';
import '../controllers/active_website_cubit.dart';

class DomainSetupWidget extends StatefulWidget {
  const DomainSetupWidget({super.key});

  @override
  State<DomainSetupWidget> createState() => _DomainSetupWidgetState();
}

class _DomainSetupWidgetState extends State<DomainSetupWidget> {
  final _domainController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final activeSite = context.read<ActiveWebsiteCubit>().state.website;
    _domainController.text = activeSite?['custom_domain'] ?? '';
  }

  Future<void> _saveDomain() async {
    final domain = _domainController.text.trim().toLowerCase();
    if (domain.isEmpty) {
      setState(() => _error = "يرجى إدخال الدومين");
      return;
    }

    // Basic domain validation regex
    final domainRegex = RegExp(r'^[a-z0-9]+([-.]?[a-z0-9]+)*\.[a-z]{2,5}$');
    if (!domainRegex.hasMatch(domain)) {
      setState(() => _error = "صيغة الدومين غير صحيحة (مثال: example.com)");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final activeCubit = context.read<ActiveWebsiteCubit>();
      final pageId = activeCubit.state.websiteId!;
      final dbService = sl<DatabaseService>();

      await dbService.updateCustomDomain(pageId, domain);

      // Update local state
      final updatedSite = Map<String, dynamic>.from(activeCubit.state.website!);
      updatedSite['custom_domain'] = domain;
      updatedSite['domain_status'] = 'pending';
      activeCubit.selectWebsite(updatedSite);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم حفظ الدومين بنجاح. يرجى إعداد الـ DNS."),
          ),
        );
      }
    } catch (e) {
      setState(
        () => _error = "حدث خطأ أثناء الحفظ. ربما هذا الدومين مستخدم بالفعل.",
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeState = context.watch<ActiveWebsiteCubit>().state;
    final hasDomain =
        activeState.customDomain != null &&
        activeState.customDomain!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDomainInputSection(),
        SizedBox(height: 32),
        if (hasDomain) _buildDNSInstructionsSection(activeState),
      ],
    );
  }

  Widget _buildDomainInputSection() {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hasDomain = _domainController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("عنوان الدومين الخاص", style: AppTypography.h3),
          SizedBox(height: 8),
          Text(
            "أدخل الدومين الذي قمت بشرائه (مثال: yourbrand.com)",
            style: AppTypography.caption,
          ),
          SizedBox(height: 24),
          if (isMobile)
            Column(
              children: [
                CustomTextField(
                  controller: _domainController,
                  hintText: "example.com",
                  onChanged: (v) => setState(() => _error = null),
                ),
                SizedBox(height: 16),
                PrimaryButton(
                  text: "حفظ الدومين",
                  width: double.infinity,
                  isLoading: _isLoading,
                  onPressed: _saveDomain,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _domainController,
                    hintText: "example.com",
                    onChanged: (_) => setState(() => _error = null),
                  ),
                ),
                SizedBox(width: 16),
                PrimaryButton(
                  text: "حفظ",
                  width: 120,
                  isLoading: _isLoading,
                  onPressed: _saveDomain,
                ),
              ],
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: AppTypography.caption.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          if (hasDomain && _error == null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "المعاينة المباشرة للرابط:",
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "https://${_domainController.text.trim().toLowerCase()}",
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDNSInstructionsSection(ActiveWebsiteState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("إعدادات الـ DNS", style: AppTypography.h3),
              _buildStatusBadge(state.domainStatus),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "يرجى إضافة السجلات التالية في لوحة تحكم الدومين الخاص بك (مثل Namecheap أو GoDaddy):",
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 24),
          _buildDNSRow("Type", "A"),
          _buildDNSRow("Name", "@"),
          _buildDNSRow("Value", "76.76.21.21"), // Vercel IP
          Divider(height: 32, color: Theme.of(context).colorScheme.outlineVariant),
          _buildDNSRow("Type", "CNAME"),
          _buildDNSRow("Name", "www"),
          _buildDNSRow("Value", "cname.vercel-dns.com"),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "تحقق الملكية (TXT Record):",
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  setState(() => _isLoading = true);
                  try {
                    final activeCubit = context.read<ActiveWebsiteCubit>();
                    final dbService = sl<DatabaseService>();
                    final newToken = await dbService
                        .refreshDomainVerificationToken(
                          activeCubit.state.websiteId!,
                        );

                    final updatedSite = Map<String, dynamic>.from(
                      activeCubit.state.website!,
                    );
                    updatedSite['domain_verification_token'] = newToken;
                    updatedSite['domain_status'] = 'pending';
                    activeCubit.selectWebsite(updatedSite);

                    if (mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("تم تجديد رمز التحقق بنجاح."),
                        ),
                      );
                  } catch (e) {
                    if (mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("فشل تجديد الرمز.")),
                      );
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
                icon: Icon(Icons.refresh_rounded, size: 14),
                label: const Text(
                  "تجديد الرمز",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildDNSRow("Name", "_landymaker-challenge"),
          _buildDNSRow("Value", state.domainVerificationToken ?? "---"),
          SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: "تحقق الآن",
                  icon: Icons.refresh_rounded,
                  isLoading: _isLoading,
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    try {
                      final activeCubit = context.read<ActiveWebsiteCubit>();
                      final dbService = sl<DatabaseService>();

                      final previousDomain = activeCubit.state.customDomain;

                      final res = await dbService.verifyCustomDomain(
                        activeCubit.state.websiteId!,
                        previousDomain: previousDomain,
                      );

                      if (res['verified'] == true) {
                        final updatedSite = Map<String, dynamic>.from(
                          activeCubit.state.website!,
                        );
                        updatedSite['domain_status'] = 'connected';
                        activeCubit.selectWebsite(updatedSite);
                        if (mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("تم توصيل الدومين بنجاح!"),
                            ),
                          );
                      } else {
                        if (mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "فشل التحقق. يرجى التأكد من إعدادات الـ DNS.",
                              ),
                            ),
                          );
                      }
                    } catch (e) {
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("حدث خطأ أثناء الاتصال بالخادم."),
                          ),
                        );
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                ),
              ),
              SizedBox(width: 16),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _isLoading
                      ? null
                      : () => _showRemoveConfirmation(context),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  tooltip: "إزالة الدومين",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRemoveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        title: const Text(
          "إزالة الدومين",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "هل أنت متأكد من رغبتك في إزالة الدومين؟ سيتم فصل الموقع عن هذا العنوان فوراً.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                final activeCubit = context.read<ActiveWebsiteCubit>();
                final dbService = sl<DatabaseService>();
                await dbService.verifyCustomDomain(
                  activeCubit.state.websiteId!,
                  action: 'delete',
                );

                final updatedSite = Map<String, dynamic>.from(
                  activeCubit.state.website!,
                );
                updatedSite['custom_domain'] = null;
                updatedSite['domain_status'] = 'pending';
                activeCubit.selectWebsite(updatedSite);
                _domainController.clear();

                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تمت إزالة الدومين بنجاح.")),
                  );
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("فشل إزالة الدومين.")),
                  );
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text("تأكيد الإزالة"),
          ),
        ],
      ),
    );
  }

  Widget _buildDNSRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: AppTypography.bodyMedium.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy_rounded, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("تم نسخ $label")));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    String text;

    switch (status) {
      case 'connected':
        color = Colors.green;
        text = "متصل";
        break;
      case 'failed':
        color = Theme.of(context).colorScheme.error;
        text = "فشل التحقق";
        break;
      default:
        color = Colors.orange;
        text = "قيد الانتظار";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
