import 'package:flutter/material.dart';
import 'package:shoedealz/utils/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkText,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
         
          _buildNotificationItem(
            icon: Icons.local_shipping,
            color: Colors.blue,
            title: "Order Shipped! 🚚",
            time: "2 hours ago",
            desc: "Your order #12345 has been shipped and is on the way.",
            isUnread: true,
          ),
         
          _buildNotificationItem(
            icon: Icons.local_offer,
            color: Colors.orange,
            title: "Flash Sale Alert! ⚡",
            time: "5 hours ago",
            desc: "Get 50% off on all Nike shoes today only. Don't miss out!",
            isUnread: false,
          ),
          _buildNotificationItem(
            icon: Icons.check_circle,
            color: Colors.green,
            title: "Payment Successful",
            time: "1 day ago",
            desc: "Your payment of Rs. 15,500 was successfully processed.",
            isUnread: false,
          ),
        ],
      ),
    );
  }

  
  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
    required String desc,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        
        color: isUnread ? Colors.blue.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isUnread ? Colors.blue.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 25,
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: isUnread
                              ? FontWeight.bold
                              : FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
