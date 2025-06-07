import 'package:flutter/material.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/widgets/custom_text.dart';

class CustomListTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const CustomListTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.trailingIcon = Icons.chevron_right,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        color: AppColors.secondBackground,
        child: ListTile(
          onTap: onTap,
          leading: Icon(leadingIcon, color: Colors.white),
          title: CustomText(
            text: title,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
          trailing: trailingIcon != null
              ? Icon(trailingIcon, color: Colors.white)
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
      ),
    );
  }
}
