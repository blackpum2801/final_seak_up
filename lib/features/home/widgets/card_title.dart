import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/widgets/custom_text.dart';

class CardTitle extends StatelessWidget {
  final String iconPath;
  final Color iconColor;
  final String title;

  const CardTitle({
    super.key,
    required this.iconPath,
    required this.title,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Card(
        color: AppColors.secondBackground,
        child: ListTile(
          leading: SvgPicture.asset(
            iconPath,
            width: 30,
            height: 30,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            fit: BoxFit.cover,
          ),
          title: CustomText(
            text: title,
            fontSize: 18,
            color: Colors.white,
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.w600,
            maxLines: 2,
            overflow: TextOverflow.visible, // Đảm bảo chữ xuống dòng
          ),
          trailing: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
              backgroundColor: iconColor,
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
