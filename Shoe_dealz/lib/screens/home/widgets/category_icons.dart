import 'package:flutter/material.dart';
import 'package:shoedealz/utils/app_colors.dart';

class CategoryIcons extends StatelessWidget {
  const CategoryIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCategoryIcon(Icons.sports_basketball, "Sports"),
        _buildCategoryIcon(Icons.directions_run, "Running"),
        _buildCategoryIcon(Icons.business_center, "Formal"),
        _buildCategoryIcon(Icons.beach_access, "Casual"),
      ],
    );
  }

  Widget _buildCategoryIcon(IconData icon, String title) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.darkText, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.darkText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
