import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/firestore_service.dart';
import '../cart/checkout_screen.dart';
import '../chat/chat_screen.dart'; 
import '../auth/login_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product; 

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedSize = 41; 
  final List<int> _sizes = [39, 40, 41, 42, 43, 44];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = user != null;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : const Color(0xFFF4F5F7), 
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black), 
                          onPressed: () => Navigator.pop(context),
                        ),
                        if (isLoggedIn)
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('favorites').doc(widget.product.id).snapshots(),
                            builder: (context, snapshot) {
                              bool isFavorite = snapshot.hasData && snapshot.data!.exists;
                              return IconButton(
                                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent, size: 28),
                                onPressed: () => FirestoreService().toggleFavorite(widget.product),
                              );
                            },
                          )
                        else
                          IconButton(
                            icon: Icon(Icons.favorite_border, color: isDark ? Colors.white : Colors.black, size: 28),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.network(
                        widget.product.imageUrl, 
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(false, isDark), _buildDot(true, isDark), _buildDot(false, isDark), _buildDot(false, isDark),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.category, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(widget.product.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
                      ),
                      // ==========================================
                      // මෙතන තමයි $ වෙනුවට Rs. දැම්මේ
                      // ==========================================
                      Text("Rs. ${widget.product.price.toStringAsFixed(2)}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(5, (index) => Icon(Icons.star, color: index < 4 ? Colors.amber : Colors.grey.shade400, size: 20)),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Select size", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                      Text("US  UK  EU", style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _sizes.map((size) => _buildSizeCircle(size, isDark)).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTab("Description", true, isDark),
                      _buildTab("Delivery", false, isDark),
                      _buildTab("Reviews", false, isDark),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text("Nothing is more comfortable and more positionable - the Nike Air Max SE celebrates heritage style with a modern touch...", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, height: 1.5)),
                  const SizedBox(height: 5),
                  const Text("More", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          boxShadow: [BoxShadow(color: isDark ? Colors.black54 : Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if(isLoggedIn) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(product: widget.product)));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, width: 1.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.chat_bubble_outline, color: isDark ? Colors.white : Colors.black, size: 26),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (isLoggedIn) {
                      Provider.of<CartProvider>(context, listen: false).addToCart(widget.product, _selectedSize);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${widget.product.name} Added to Cart!'), backgroundColor: Colors.green.shade600, duration: const Duration(seconds: 2)),
                      );
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                    foregroundColor: isDark ? Colors.white : Colors.black,
                    elevation: 0,
                    side: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.black, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Add to Cart", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (isLoggedIn) {
                      Provider.of<CartProvider>(context, listen: false).addToCart(widget.product, _selectedSize);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutScreen()));
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Buy Now", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 20 : 8,
      decoration: BoxDecoration(color: isActive ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.grey[700] : Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildSizeCircle(int size, bool isDark) {
    bool isSelected = _selectedSize == size;
    return GestureDetector(
      onTap: () => setState(() => _selectedSize = size),
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? Colors.redAccent : (isDark ? Colors.grey.shade700 : Colors.grey.shade300), width: isSelected ? 2 : 1),
          color: isDark ? Colors.grey[800] : Colors.white,
        ),
        child: Center(
          child: Text(
            size.toString(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.redAccent : (isDark ? Colors.white : Colors.black)),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isActive, bool isDark) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isActive ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.grey[500] : Colors.grey))),
        const SizedBox(height: 5),
        if (isActive) Container(height: 2, width: 40, color: isDark ? Colors.white : Colors.black)
      ],
    );
  }
}