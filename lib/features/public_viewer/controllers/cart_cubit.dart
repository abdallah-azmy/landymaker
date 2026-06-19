import 'package:flutter_bloc/flutter_bloc.dart';

class CartState {
  final List<Map<String, dynamic>> items;
  final double totalPrice;
  final String whatsappNumber;
  final bool isVisible;
  final bool isFolded;
  final DateTime? lastAddedTimestamp;

  CartState({
    required this.items,
    required this.totalPrice,
    required this.whatsappNumber,
    this.isVisible = true,
    this.isFolded = true,
    this.lastAddedTimestamp,
  });

  CartState copyWith({
    List<Map<String, dynamic>>? items,
    double? totalPrice,
    String? whatsappNumber,
    bool? isVisible,
    bool? isFolded,
    DateTime? lastAddedTimestamp,
  }) {
    return CartState(
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      isVisible: isVisible ?? this.isVisible,
      isFolded: isFolded ?? this.isFolded,
      lastAddedTimestamp: lastAddedTimestamp ?? this.lastAddedTimestamp,
    );
  }
}

class CartCubit extends Cubit<CartState> {
  CartCubit()
      : super(CartState(
          items: [],
          totalPrice: 0.0,
          whatsappNumber: '',
          isVisible: true,
          isFolded: true,
        ));

  void setWhatsappNumber(String number) {
    emit(state.copyWith(whatsappNumber: number));
  }

  void setVisibility(bool visible) {
    emit(state.copyWith(isVisible: visible));
  }

  void setFolded(bool folded) {
    emit(state.copyWith(isFolded: folded));
  }

  void toggleFolded() {
    emit(state.copyWith(isFolded: !state.isFolded));
  }

  void addItem(Map<String, dynamic> product) {
    final List<Map<String, dynamic>> currentItems = List.from(state.items);
    final String productId =
        product['id']?.toString() ?? product['name']?.toString() ?? 'unknown';

    // Check if item already exists
    final int existingIndex = currentItems.indexWhere((item) =>
        (item['id']?.toString() ?? item['name']?.toString() ?? 'unknown') ==
        productId);

    if (existingIndex >= 0) {
      // Increment quantity
      final existingItem =
          Map<String, dynamic>.from(currentItems[existingIndex]);
      existingItem['cart_quantity'] =
          (existingItem['cart_quantity'] as int? ?? 1) + 1;
      currentItems[existingIndex] = existingItem;
    } else {
      // Add new item with quantity 1
      final newItem = Map<String, dynamic>.from(product);
      newItem['cart_quantity'] = 1;
      currentItems.add(newItem);
    }

    _updateState(currentItems, updateTimestamp: true);
  }

  void removeItem(String productId) {
    final List<Map<String, dynamic>> currentItems = List.from(state.items);
    currentItems.removeWhere((item) =>
        (item['id']?.toString() ?? item['name']?.toString() ?? 'unknown') ==
        productId);
    _updateState(currentItems);
  }

  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }

    final List<Map<String, dynamic>> currentItems = List.from(state.items);
    final int existingIndex = currentItems.indexWhere((item) =>
        (item['id']?.toString() ?? item['name']?.toString() ?? 'unknown') ==
        productId);

    if (existingIndex >= 0) {
      final existingItem =
          Map<String, dynamic>.from(currentItems[existingIndex]);
      existingItem['cart_quantity'] = newQuantity;
      currentItems[existingIndex] = existingItem;
      _updateState(currentItems);
    }
  }

  void clearCart() {
    emit(state.copyWith(items: [], totalPrice: 0.0));
  }

  void _updateState(List<Map<String, dynamic>> currentItems,
      {bool updateTimestamp = false}) {
    double total = 0.0;
    for (var item in currentItems) {
      final double price = _parsePrice(item['price']);
      final int qty = item['cart_quantity'] as int? ?? 1;
      total += price * qty;
    }
    emit(state.copyWith(
      items: currentItems,
      totalPrice: total,
      lastAddedTimestamp: updateTimestamp ? DateTime.now() : state.lastAddedTimestamp,
    ));
  }

  double _parsePrice(dynamic raw) {
    if (raw == null) return 0.0;
    return double.tryParse(raw.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ??
        0.0;
  }
}
