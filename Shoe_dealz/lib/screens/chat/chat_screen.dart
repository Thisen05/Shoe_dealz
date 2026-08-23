import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoedealz/utils/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/theme_provider.dart';
import '../../services/firestore_service.dart';

class ChatScreen extends StatefulWidget {
  final Product product; // සපත්තුවේ විස්තර ගන්න අලුතින් දැම්මා

  const ChatScreen({super.key, required this.product});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      String text = _messageController.text.trim();
      _messageController.clear();
      // සපත්තුවත් එක්කම මැසේජ් එක යවනවා
      await _firestoreService.sendProductMessage(widget.product, text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Store එක වෙනුවට අදාළ සපත්තුවේ පින්තූරය පෙන්වනවා
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Image.network(widget.product.imageUrl, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name, // සපත්තුවේ නම
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.darkText),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  Text('ShoeDealz Support', style: GoogleFonts.poppins(fontSize: 11, color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // අදාළ සපත්තුවේ මැසේජ් විතරක් ගන්නවා
              stream: _firestoreService.getProductChatMessages(widget.product.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text("Ask us anything about\n${widget.product.name}!", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: isDark ? Colors.grey[500] : Colors.grey)),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;
                    bool isMe = messageData['isMe'] ?? true;
                    String text = messageData['text'] ?? '';

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? const Color.fromARGB(255, 163, 224, 248).withOpacity(isDark ? 0.8 : 1) : (isDark ? Colors.grey[800] : Colors.white),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0), bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 5, offset: const Offset(0, 2))],
                        ),
                        child: Text(text, style: GoogleFonts.poppins(fontSize: 14, color: isMe ? (isDark ? Colors.black87 : Colors.white) : (isDark ? Colors.white : AppColors.darkText))),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: isDark ? Colors.grey[900] : Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: GoogleFonts.poppins(fontSize: 14, color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(hintText: 'Ask about this shoe...', hintStyle: GoogleFonts.poppins(color: Colors.grey[500]), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
                    child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 20), onPressed: _sendMessage),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}