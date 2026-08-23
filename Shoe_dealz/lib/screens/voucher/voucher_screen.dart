import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shoedealz/utils/app_colors.dart';

class VoucherScreen extends StatelessWidget {
  const VoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "My Vouchers",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkText,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          
          _buildVoucherCard(
            context,
            "WELCOME10",
            "10% Off on your first order!",
            const Color.fromARGB(255, 215, 244, 246),
          ),
          _buildVoucherCard(
            context,
            "SAVE20",
            "20% Off on orders above Rs. 5000",
            Colors.green,
          ),
          _buildVoucherCard(
            context,
            "FREEDEL",
            "Free Delivery on all orders",
            Colors.blue,
          ),
        ],
      ),
    );
  }

  
  Widget _buildVoucherCard(BuildContext context, String code, String desc, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: color, width: 8),
          ), 
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(desc, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // කූපන් කෝඩ් එක Clipboard එකට Copy කරනවා
                Clipboard.setData(ClipboardData(text: code));
                
                // Copy වුණා කියලා පොඩි මැසේජ් එකක් (SnackBar) පෙන්වනවා
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$code copied to clipboard!"),
                    backgroundColor: Colors.black87,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Copy"),
            ),
          ],
        ),
      ),
    );
  }
}