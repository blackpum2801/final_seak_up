import 'package:flutter/material.dart';
import 'package:speak_up/core/constants/asset_color.dart';

class TypeGame extends StatelessWidget {
  final String iconPath;
  final int colorIndex;
  final String title;
  final VoidCallback? onTap;

  const TypeGame({
    Key? key,
    required this.iconPath,
    required this.title,
    this.colorIndex = 0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.getCourseCardColor(colorIndex),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: "OpenSans",
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
