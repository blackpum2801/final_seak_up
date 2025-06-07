import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/widgets/custom_text.dart';

class CardTitleExpect extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final Color iconColor;
  const CardTitleExpect({
    super.key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Card(
        color: AppColors.secondBackground,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              SvgPicture.asset(
                iconPath,
                width: 30,
                height: 30,
                color: iconColor,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: title,
                      maxLines: 2,
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    CustomText(
                      text: subtitle,
                      maxLines: 3,
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.keyboard_arrow_right_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
