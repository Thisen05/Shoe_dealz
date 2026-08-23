import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoedealz/providers/cart_provider.dart';
import 'package:shoedealz/providers/theme_provider.dart';
import 'package:shoedealz/services/firestore_service.dart';

import 'payment_screen.dart'; 

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _voucherController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  bool _isLoading = false; 
  String _selectedPaymentMethod = 'COD'; // 'COD' හෝ 'Card'

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Delivery Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController, 
              maxLines: 3,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Enter your full address...",
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : const Color(0xFFF4F5F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              "Voucher Code",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _voucherController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: "Enter code (e.g. SAVE20)",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : const Color(0xFFF4F5F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (_voucherController.text.isEmpty) return;
                    bool isValid = await cart.applyVoucher(_voucherController.text.trim().toUpperCase());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(cart.voucherMessage),
                          backgroundColor: isValid ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.blueAccent : Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Apply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            
            if (cart.appliedVoucher.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Applied: ${cart.appliedVoucher} ${cart.appliedVoucher == 'FREEDEL' ? '(Free Delivery)' : '(${(cart.discountPercent * 100).toInt()}% OFF)'}",
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
              
            const SizedBox(height: 25),
            Text(
              "Payment Method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 15),
            
            // 1. Cash on Delivery Option
            GestureDetector(
              onTap: () => setState(() => _selectedPaymentMethod = 'COD'),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _selectedPaymentMethod == 'COD' ? Colors.green : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.money, color: Colors.green, size: 30),
                    const SizedBox(width: 15),
                    Text(
                      "Cash on Delivery",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                    ),
                    const Spacer(),
                    if (_selectedPaymentMethod == 'COD')
                      const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // 2. Credit/Debit Card Option
            GestureDetector(
              onTap: () => setState(() => _selectedPaymentMethod = 'Card'),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _selectedPaymentMethod == 'Card' ? Colors.blueAccent : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.credit_card, color: Colors.blueAccent, size: 30),
                    const SizedBox(width: 15),
                    Text(
                      "Credit / Debit Card",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                    ),
                    const Spacer(),
                    if (_selectedPaymentMethod == 'Card')
                      const Icon(Icons.check_circle, color: Colors.blueAccent),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Place Order / Pay Now Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (cart.items.isEmpty || _isLoading) ? null : () async {
                  String address = _addressController.text.trim();
                  
                  if (address.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a delivery address!"), backgroundColor: Colors.redAccent),
                    );
                    return;
                  }

                  
                  if (_selectedPaymentMethod == 'Card') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(deliveryAddress: address),
                      ),
                    );
                    return; 
                  }

                 
                  setState(() => _isLoading = true);
                  bool success = await FirestoreService().placeOrder(address, cart.totalAmount);
                  setState(() => _isLoading = false);

                  if (success) {
                    cart.clearCart();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Order Placed Successfully! 🎉"), backgroundColor: Colors.green),
                      );
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to place order. Try again!"), backgroundColor: Colors.redAccent),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedPaymentMethod == 'Card' ? Colors.blueAccent : (isDark ? Colors.grey[700] : Colors.black),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text(
                     
                      _selectedPaymentMethod == 'Card' 
                          ? "Pay Now (Rs. ${cart.totalAmount.toStringAsFixed(2)})" 
                          : "Place Order (Rs. ${cart.totalAmount.toStringAsFixed(2)})",
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}