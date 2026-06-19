import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/pixel_event_service.dart';
import '../controllers/cart_cubit.dart';
import 'package:toastification/toastification.dart';

class FloatingCartWidget extends StatefulWidget {
  final ValueNotifier<bool>? isStickyVisible;
  const FloatingCartWidget({super.key, this.isStickyVisible});

  @override
  State<FloatingCartWidget> createState() => _FloatingCartWidgetState();
}

class _FloatingCartWidgetState extends State<FloatingCartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _triggerBounce() {
    _bounceController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartCubit, CartState>(
      listenWhen: (prev, curr) =>
          prev.lastAddedTimestamp != curr.lastAddedTimestamp,
      listener: (context, state) {
        if (state.lastAddedTimestamp != null) {
          _triggerBounce();
        }
      },
      builder: (context, state) {
        if (!state.isVisible || state.items.isEmpty) {
          return const SizedBox.shrink();
        }

        final int totalQuantity = state.items.fold(
            0, (sum, item) => sum + (item['cart_quantity'] as int? ?? 1));

        return LayoutBuilder(builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth > 900;

          return ValueListenableBuilder<bool>(
            valueListenable: widget.isStickyVisible ?? ValueNotifier(false),
            builder: (context, isSticky, _) {
              return AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                bottom: isSticky ? 90 : 24,
                start: isDesktop ? null : 24,
                end: isDesktop ? 24 : null,
                child: isDesktop
                    ? _buildDesktopSidebarCart(context, state, totalQuantity)
                    : _buildMobileFoldableCart(context, state, totalQuantity),
              );
            },
          );
        });
      },
    );
  }

  Widget _buildMobileFoldableCart(
      BuildContext context, CartState state, int totalQuantity) {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: GestureDetector(
        onTap: () => _showCartDialog(context, state),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_cart_rounded, color: Colors.white),
              if (!state.isFolded) ...[
                const SizedBox(width: 12),
                Text(
                  "${state.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "$totalQuantity",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSidebarCart(
      BuildContext context, CartState state, int totalQuantity) {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: FloatingActionButton.extended(
        heroTag: 'cart_fab_desktop',
        onPressed: () => _showCartDialog(context, state),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.shopping_cart_rounded),
        label: Text(
          "السلة (${state.totalPrice.toStringAsFixed(2)})",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
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
                  maxWidth: 500,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 5)
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "سلة المشتريات",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          onPressed: () => Navigator.of(ctx).pop(),
                        )
                      ],
                    ),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 16),
                    if (cartState.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text("السلة فارغة",
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.onSurface),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        priceStr,
                                        style: TextStyle(
                                            color: Theme.of(context).colorScheme.secondary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
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
                    if (cartState.items.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "الإجمالي:",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                          Text(
                            cartState.totalPrice.toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary),
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
                            backgroundColor: const Color(0xFF25D366),
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
    String cleanNumber = state.whatsappNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('https://wa.me/$cleanNumber?text=$encodedMessage');

    if (await canLaunchUrl(url)) {
      PixelEventService.trackPurchase(state.totalPrice, 'USD');
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
