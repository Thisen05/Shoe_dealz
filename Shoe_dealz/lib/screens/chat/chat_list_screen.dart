import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoedealz/utils/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/theme_provider.dart';
import '../../services/firestore_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Messages', style: GoogleFonts.poppins(color: isDark ? Colors.white : AppColors.darkText, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.darkText),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No chats yet.\nExplore shoes and ask us!", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: isDark ? Colors.grey[500] : Colors.grey)));
          }

          final chatRooms = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final roomData = chatRooms[index].data() as Map<String, dynamic>;
              
              String lastMessage = roomData['lastMessage'] ?? '';
              String productName = roomData['productName'] ?? 'Shoe';
              String productImage = roomData['productImage'] ?? '';
              
              Timestamp? ts = roomData['timestamp'] as Timestamp?;
              String timeString = "Just now";
              if (ts != null) {
                DateTime dt = ts.toDate();
                timeString = "${dt.hour > 12 ? dt.hour - 12 : dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 5, offset: const Offset(0, 2))],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 50, height: 50, padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: Image.network(productImage, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey)),
                  ),
                  title: Text(
                    productName,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : AppColors.darkText),
                  ),
                  subtitle: Text(
                    lastMessage,
                    style: GoogleFonts.poppins(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(timeString, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                  onTap: () {
                    // ===============================================
                    // මෙන්න මෙතන තමයි වෙනස් කළේ (Product.fromMap දැම්මා)
                    // ===============================================
                    Product chatProduct = Product.fromMap({
                      'name': productName,
                      'imageUrl': productImage,
                      'price': 0.0,
                      'category': 'Chat',
                      'description': '',
                      'sizes': [], 
                    }, roomData['productId'] ?? 'dummy_id');

                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(product: chatProduct)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}