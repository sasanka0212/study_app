import 'package:flutter/material.dart';
import 'package:study_app/utils/sizes.dart';
import 'package:study_app/widgets/category_box_shadow.dart';

class CategoryCardVertical extends StatelessWidget {
  const CategoryCardVertical({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        boxShadow: [CategoryBoxShadow.verticalProductShadow],
        borderRadius: BorderRadius.circular(Sizes.productImageSize),
        color: Colors.white,
      ),
      child: Column(
        children: [
          
        ],
      ),
    );
  }
}