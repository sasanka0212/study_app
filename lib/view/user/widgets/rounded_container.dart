import 'package:flutter/material.dart';
import 'package:study_app/utils/colors.dart';
import 'package:study_app/utils/sizes.dart';

class RoundedContainer extends StatelessWidget {
  //required variables
  final double? width;
  final double? height;
  final double radius;
  final Widget? child;
  final bool showBorder;
  final Color borderColor;
  final Color backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const RoundedContainer({
    super.key,
    this.child,
    this.height,
    this.width,
    this.margin,
    this.padding,
    this.radius = Sizes.cardRadius,
    this.showBorder = true,
    this.borderColor = Colors.white,
    this.backgroundColor = borderPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
