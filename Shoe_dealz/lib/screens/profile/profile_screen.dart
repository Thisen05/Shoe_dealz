import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../orders/my_orders_screen.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = user != null;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    final String userName = isLoggedIn ? (user.displayName ?? 'My Account') : 'Guest User';
    final String userEmail = isLoggedIn ? (user.email ?? '') : 'Please login to manage your profile';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text("My Profile", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 30),
              
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: isDark ? Colors.grey[800] : const Color(0xFFE0E0E0),
                      child: Icon(Icons.person, size: 50, color: isDark ? Colors.grey[400] : Colors.black54),
                    ),
                    if (isLoggedIn)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: isDark ? Colors.white : Colors.black, shape: BoxShape.circle),
                          child: Icon(Icons.camera_alt, color: isDark ? Colors.black : Colors.white, size: 16),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              
              Text(userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 5),
              Text(userEmail, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey)),
              const SizedBox(height: 40),

              _buildMenuOption(
                Icons.shopping_bag_outlined, 
                "My Orders", 
                isDark,
                () {
                  if (isLoggedIn) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen()));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  }
                }
              ),
              _buildMenuOption(
                Icons.favorite_border, 
                "Favorites", 
                isDark,
                () {
                  if (isLoggedIn) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  }
                }
              ),
              _buildMenuOption(Icons.settings_outlined, "Settings", isDark, () {}),
              const SizedBox(height: 20),
              Divider(color: isDark ? Colors.grey[800] : Colors.grey[300]),
              const SizedBox(height: 20),

              isLoggedIn ? _buildLogoutButton(context, isDark) : _buildLoginButton(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String title, bool isDark, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: isDark ? Colors.grey[800] : const Color(0xFFF4F5F7), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: isDark ? Colors.white : Colors.black),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.grey[400] : Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
    );
  }

  Widget _buildLoginButton(BuildContext context, bool isDark) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
        child: Icon(Icons.login, color: isDark ? Colors.greenAccent : Colors.green),
      ),
      title: Text("Login", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.greenAccent : Colors.green)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.grey[400] : Colors.grey),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: isDark ? Colors.red.withOpacity(0.2) : Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.logout, color: Colors.redAccent),
      ),
      title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.grey[400] : Colors.grey),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            title: Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            content: Text("Are you sure you want to log out?", style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (context) => const HomeScreen()), 
                      (route) => false
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Yes, Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
    );
  }
}