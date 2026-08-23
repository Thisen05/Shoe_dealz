import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/theme_provider.dart';
import 'checkout_screen.dart'; 

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          "My Cart",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 15),
                  Text(
                    "Your cart is empty!",
                    style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : const Color(0xFFF4F5F7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Image.network(
                                cartItem.product.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cartItem.product.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  
                                  Text(
                                    "Rs. ${cartItem.product.price.toStringAsFixed(2)} x ${cartItem.quantity} (Size: ${cartItem.size})",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () {
                                cartProvider.removeItem(cartItem.product.id, cartItem.size);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Bill Summary එක
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : const Color(0xFFF4F5F7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      )
                    ]
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Subtotal
                       
                        _buildSummaryRow("Subtotal:", "Rs. ${cartProvider.subtotal.toStringAsFixed(2)}", isDark),
                        const SizedBox(height: 10),
                        
                        // Delivery Fee
                        _buildSummaryRow(
                          "Delivery Fee:", 
                          cartProvider.deliveryFee == 0 ? "Free" : "Rs. ${cartProvider.deliveryFee.toStringAsFixed(2)}", 
                          isDark,
                          isGreen: cartProvider.deliveryFee == 0
                        ),
                        const SizedBox(height: 10),

                        // Discount (Discount එකක් තියෙනවා නම් විතරක් පෙන්වන්න)
                        if (cartProvider.discountAmount > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildSummaryRow(
                              "Discount (${(cartProvider.discountPercent * 100).toInt()}%):", 
                              "- Rs. ${cartProvider.discountAmount.toStringAsFixed(2)}", 
                              isDark,
                              isGreen: true
                            ),
                          ),
                          
                        Divider(color: isDark ? Colors.grey[800] : Colors.grey[300], height: 20, thickness: 1),
                        
                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Amount:",
                              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                           
                            Text(
                              "Rs. ${cartProvider.totalAmount.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 22, 
                                fontWeight: FontWeight.w900, 
                                color: isDark ? Colors.white : Colors.black
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Checkout Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: cartItems.isEmpty ? null : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.blueAccent : const Color(0xFF222831),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              "Proceed to Checkout",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  
  Widget _buildSummaryRow(String title, String amount, bool isDark, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Expanded(
          flex: 3,
          child: Text(
            title,
            style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w600),
          ),
        ),
        // 
        Expanded(
          flex: 2,
          child: Text(
            amount,
            textAlign: TextAlign.right, 
            style: TextStyle(
              fontSize: 15, 
              fontWeight: FontWeight.bold, 
              color: isGreen ? Colors.green : (isDark ? Colors.white : Colors.black87)
            ),
          ),
        ),
      ],
    );
  }
}