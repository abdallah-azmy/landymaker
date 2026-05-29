import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../controllers/cart_cubit.dart';
import 'package:toastification/toastification.dart';

class FloatingCartWidget extends StatelessWidget {
  const FloatingCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return const SizedBox.shrink();
        }

        final int totalQuantity = state.items.fold(
            0, (sum, item) => sum + (item['cart_quantity'] as int? ?? 1));

        return Positioned(
          bottom: 24,
          left: 24, // Assuming RTL, bottom-left is suitable. Or right. Let's use left for LTR and right for RTL.
          // Let's just use bottom left for floating action button.
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton(
                heroTag: 'cart_fab',
                onPressed: () => _showCartDialog(context, state),
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                elevation: 8,
                child: const Icon(Icons.shopping_cart_rounded),
              ),
              if (totalQuantity > 0)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.dangerRed,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$totalQuantity',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showCartDialog(BuildContext context, CartState state) {
    final cubit = context.read<CartCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              return Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: 500, // Limit width on web
                ),
                decoration: const BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 5)
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "سلة المشتريات",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: () => Navigator.of(ctx).pop(),
                        )
                      ],
                    ),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 16),

                    // Items List
                    if (cartState.items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Text("السلة فارغة",
                            style: TextStyle(color: AppColors.textSecondary)),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: cartState.items.length,
                          separatorBuilder: (_, __) =>
                              const Divider(color: Colors.white12, height: 24),
                          itemBuilder: (context, index) {
                            final item = cartState.items[index];
                            final id = item['id']?.toString() ??
                                item['name']?.toString() ??
                                'unknown';
                            final qty = item['cart_quantity'] as int? ?? 1;
                            final priceStr = item['price']?.toString() ?? '';
                            final name = item['name']?.toString() ?? 'Product';
                            final imageUrl = item['image_url']?.toString();

                            return Row(
                              children: [
                                // Image
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(12),
                                    image: imageUrl != null && imageUrl.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(imageUrl),
                                            fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: imageUrl == null || imageUrl.isEmpty
                                      ? const Icon(Icons.image,
                                          color: Colors.white24)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        priceStr,
                                        style: const TextStyle(
                                            color: AppColors.secondary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                // Quantity Controls
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 16),
                                        onPressed: () => cubit.updateQuantity(
                                            id, qty - 1),
                                        splashRadius: 16,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                            minWidth: 32, minHeight: 32),
                                      ),
                                      Text('$qty',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 16),
                                        onPressed: () => cubit.updateQuantity(
                                            id, qty + 1),
                                        splashRadius: 16,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                            minWidth: 32, minHeight: 32),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 24),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 16),

                    // Total & Checkout
                    if (cartState.items.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "الإجمالي:",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary),
                          ),
                          Text(
                            "${cartState.totalPrice.toStringAsFixed(2)}", // Assuming currency is appended manually or implied
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () => _completeOrder(context, cartState),
                          icon: const Icon(Icons.send_rounded),
                          label: const Text(
                            "إكمال الطلب عبر واتساب",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _completeOrder(BuildContext context, CartState state) async {
    if (state.whatsappNumber.isEmpty) {
      toastification.show(
        context: context,
        type: ToastificationType.warning,
        title: const Text('تعذر إرسال الطلب'),
        description: const Text('عذراً، صاحب الصفحة لم يقم بإعداد رقم واتساب لاستقبال الطلبات.'),
        autoCloseDuration: const Duration(seconds: 4),
      );
      return;
    }

    final StringBuffer message = StringBuffer();
    message.writeln("مرحباً، أود طلب المنتجات التالية:");
    message.writeln("");

    for (var item in state.items) {
      final name = item['name']?.toString() ?? 'منتج غير معروف';
      final qty = item['cart_quantity'] as int? ?? 1;
      final price = item['price']?.toString() ?? '';
      message.writeln("- $name (الكمية: $qty) - السعر: $price");
    }

    message.writeln("");
    message.writeln("الإجمالي: ${state.totalPrice.toStringAsFixed(2)}");

    final encodedMessage = Uri.encodeComponent(message.toString());
    
    // Clean the phone number (remove +, spaces, dashes)
    String cleanNumber = state.whatsappNumber.replaceAll(RegExp(r'[^0-9]'), '');
    
    final url = Uri.parse('https://wa.me/$cleanNumber?text=$encodedMessage');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text('خطأ'),
          description: const Text('تعذر فتح واتساب. تأكد من تثبيت التطبيق.'),
          autoCloseDuration: const Duration(seconds: 4),
        );
      }
    }
  }
}
