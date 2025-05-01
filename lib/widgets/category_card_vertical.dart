import 'package:flutter/material.dart';
import 'package:study_app/externals/links.dart';
import 'package:study_app/utils/colors.dart';
import 'package:study_app/utils/sizes.dart';
import 'package:study_app/widgets/category_box_shadow.dart';
import 'package:study_app/widgets/rounded_container.dart';

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
          //Thubanil/image/like tag
          RoundedContainer(
            height: 100,
            padding: EdgeInsets.all(Sizes.smallPadding),
            backgroundColor: light,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  height: 80,
                  width: 80,
                  child: Image.network(devOpsImage),
                ),
              ],
            ),
          ),
          //info tag/description
        ],
      ),
    );
  }
}