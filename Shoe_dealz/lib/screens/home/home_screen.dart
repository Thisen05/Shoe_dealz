import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoedealz/utils/app_colors.dart';
import 'package:shoedealz/screens/chat/chat_list_screen.dart';
import 'package:shoedealz/screens/cart/cart_screen.dart';
import 'package:shoedealz/screens/orders/my_orders_screen.dart';
import '../product/product_details_screen.dart';
import 'package:shoedealz/screens/voucher/voucher_screen.dart';
import 'package:shoedealz/screens/profile/profile_screen.dart';
import 'package:shoedealz/screens/home/widgets/search_bar.dart';
import '../../services/firestore_service.dart';
import '../../models/product_model.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../notifications/notification_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final FirestoreService _firestoreService = FirestoreService();

  String _selectedCategory = "All";
  final List<String> _categories = ["All", "Running", "Sneakers", "Formal", "Casual"];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Guest'; 
    final userEmail = user?.email ?? 'No email';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Theme එකට අනුව පාට හැදෙන්න දැම්මා

      drawer: _buildDrawer(userName, userEmail), 

      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        surfaceTintColor: Colors.transparent, 
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        title: Text(
          "Hello, $userName 👋", 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_offer_outlined, color: AppColors.primaryColor, size: 26),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VoucherScreen())),
          ),
          // මෙතන තමයි Notification Screen එකට යන ලින්ක් එක හැදුවේ
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
            },
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: _selectedIndex == 0
          ? _buildHomeBody()
          : _selectedIndex == 1
          ? const CartScreen()
          : const ProfileScreen(), 

      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen())),
              backgroundColor: AppColors.primaryColor, 
              elevation: 4,
              child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryColor, 
        unselectedItemColor: AppColors.lightText,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        type: BottomNavigationBarType.fixed,
        elevation: 15,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildHomeBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomSearchBar(),
          const SizedBox(height: 20),
          _buildPromoBanner(),
          const SizedBox(height: 25),
          _buildCategoryList(),
          const SizedBox(height: 20),

          StreamBuilder<List<Product>>(
            stream: _firestoreService.getProducts(_selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              if (snapshot.hasError) {
                return const Center(child: Text("දෝෂයක් ඇති විය!", style: TextStyle(color: Colors.red)));
              }

              final products = snapshot.data ?? [];

              if (products.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text("මේ Category එකේ සපත්තු දැනට නැත.", style: TextStyle(color: Colors.grey)),
                  )
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), 
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  return _buildProductCard(products[index]); 
                },
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : const Color(0xFFF4F5F7), // Dark Mode එකට පාට වෙනස් කළා
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "15% Discount",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                const Text(
                  "on your first purchase",
                  style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Shop now",
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          Positioned(
            right: -15,
            bottom: 5,
            top: 5,
            child: Transform.rotate(
              angle: -0.2,
              child: Image.asset(
                'assets/images/shoe.png', 
                width: 140,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          bool isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = category);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.transparent, 
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected 
                      ? (isDark ? Colors.black : Colors.white) 
                      : Colors.grey[500],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return GestureDetector(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(product: product),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : const Color(0xFFF4F5F7), 
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Image.network(
                  product.imageUrl, 
                  width: 120, 
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            Text(
              product.name, 
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // ==========================================
                  // මෙතන තමයි $ වෙනුවට Rs. දැම්මේ
                  // ==========================================
                  "Rs. ${product.price.toStringAsFixed(2)}", 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.arrow_forward, size: 16, color: isDark ? Colors.white : Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(String userName, String userEmail) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryColor), 
            accountName: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            accountEmail: Text(userEmail, style: const TextStyle(color: Colors.white70)),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.primaryColor, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text("My Orders"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen()));
            },
          ),
          const Divider(),
          
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: const Text("Dark Mode"),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: themeProvider.isDarkMode,
                activeColor: AppColors.primaryColor,
                onChanged: (bool value) {
                  themeProvider.toggleTheme(value); 
                },
              );
            },
          ),
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent), 
            title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}