import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class CartItem {
  final Product product;
  final int size;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    this.quantity = 1,
  });
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  final FirestoreService _firestoreService = FirestoreService();

  List<CartItem> get items => _items;

  String _appliedVoucher = '';
  double _discountPercent = 0.0;
  String _voucherMessage = ''; 
  
  // 1. Delivery Fee 
  final double _baseDeliveryFee = 10.0; 

  String get appliedVoucher => _appliedVoucher;
  double get discountPercent => _discountPercent;
  String get voucherMessage => _voucherMessage;
  int get itemCount => _items.length;



  // 2. Subtotal 
  double get subtotal => _items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  // 3. Discount Amount
  double get discountAmount => subtotal * _discountPercent;

  // 4. Delivery Fee
  double get deliveryFee => _appliedVoucher == 'FREEDEL' ? 0.0 : _baseDeliveryFee;

  // 5. Total Amount 
  double get totalAmount {
    if (_items.isEmpty) return 0.0;
    return subtotal - discountAmount + deliveryFee;
  }

  

  // Cart 
  void addToCart(Product product, int size) {
    int index = _items.indexWhere((item) => item.product.id == product.id && item.size == size);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product, size: size));
    }
    notifyListeners();
    _firestoreService.addToCartFirebase(product, size, 1);
  }

  
  void removeItem(String productId, int size) {
    _items.removeWhere((item) => item.product.id == productId && item.size == size);
    
    
    if (_items.isEmpty) {
      _appliedVoucher = '';
      _discountPercent = 0.0;
      _voucherMessage = '';
    }
    notifyListeners();
    _firestoreService.removeFromCartFirebase(productId, size);
  }

  
  Future<bool> applyVoucher(String code) async {
    double currentSubtotal = subtotal;

    if (code == 'WELCOME10') {
      bool hasOrders = await _firestoreService.hasPreviousOrders();
      if (hasOrders) {
        _voucherMessage = "This voucher is for your first order only!";
        return false;
      }
      _appliedVoucher = code;
      _discountPercent = 0.10; // 10% Discount
      _voucherMessage = "10% Welcome Discount Applied! 🎉";
      notifyListeners();
      return true;

    } else if (code == 'SAVE20') {
      
      if (currentSubtotal < 50) {
        _voucherMessage = "Minimum order value is \$50!";
        return false;
      }
      _appliedVoucher = code;
      _discountPercent = 0.20; // 20% Discount
      _voucherMessage = "20% Discount Applied! 🎉";
      notifyListeners();
      return true;

    } else if (code == 'FREEDEL') {
      
      if (currentSubtotal < 100) {
        _voucherMessage = "Minimum order value is \$100 for Free Delivery!";
        return false;
      }
      _appliedVoucher = code;
      _discountPercent = 0.0; 
      _voucherMessage = "Free Delivery Applied! 🚚";
      notifyListeners();
      return true;
    }

    _voucherMessage = "Invalid Voucher Code! ❌";
    return false;
  }

 
  void clearCart() {
    _items.clear();
    _appliedVoucher = '';
    _discountPercent = 0.0;
    _voucherMessage = '';
    notifyListeners();
    _firestoreService.clearCartFirebase();
  }
}