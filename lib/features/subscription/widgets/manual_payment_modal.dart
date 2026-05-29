import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/primary_button.dart';

class ManualPaymentModal extends StatefulWidget {
  final String planName;
  final double price;

  const ManualPaymentModal({super.key, required this.planName, required this.price});

  @override
  State<ManualPaymentModal> createState() => _ManualPaymentModalState();
}

class _ManualPaymentModalState extends State<ManualPaymentModal> {
  PlatformFile? _pickedFile;
  bool _isUploading = false;

  Future<void> _pickScreenshot() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Upgrade to ${widget.planName}", style: AppTypography.h2),
          const SizedBox(height: 8),
          Text("Amount to Pay: ${widget.price} EGP", style: AppTypography.bodyLarge.copyWith(color: AppColors.secondary)),
          const SizedBox(height: 24),
          _buildPaymentGuide("Vodafone Cash", "010XXXXXXXX"),
          _buildPaymentGuide("InstaPay", "user@instapay"),
          const SizedBox(height: 32),
          Text("Upload Payment Screenshot", style: AppTypography.h3),
          const SizedBox(height: 12),
          _buildUploader(),
          const SizedBox(height: 24),
          PrimaryButton(
            text: "Submit Request",
            onPressed: _pickedFile == null ? null : () {}, // Logic to call Supabase
            isLoading: _isUploading,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentGuide(String method, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_rounded, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Text("$method: ", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          Text(detail, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildUploader() {
    return InkWell(
      onTap: _pickScreenshot,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: _pickedFile != null 
          ? Center(child: Text(_pickedFile!.name))
          : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_rounded, color: AppColors.textMuted),
                SizedBox(height: 8),
                Text("Click to select image"),
              ],
            ),
      ),
    );
  }
}
