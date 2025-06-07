import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/core/constants/assets.dart';
import 'package:speak_up/widgets/custom_text.dart';

class TopicCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final String lesson;
  final bool isHorizontal;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onTap; // ✅ thêm onTap

  const TopicCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.lesson,
    this.isHorizontal = true,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.onTap, // ✅ thêm onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.background,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Card(
          color: AppColors.secondBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: isHorizontal
              ? SizedBox(
                  width: 250,
                  height: 120,
                  child: Row(
                    children: [
                      _buildImage(120, 120, alignLeft: true),
                      Expanded(child: _buildTextContent(16, 13, 12)),
                    ],
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  height: 280,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImage(double.infinity, 160, alignLeft: false),
                      Expanded(child: _buildTextContent(18, 14, 14)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildImage(double width, double height, {required bool alignLeft}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: image,
            width: width,
            height: height,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[300]),
            errorWidget: (context, url, error) => Image.asset(
              AppAssets.imageConversation1,
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 8,
            left: alignLeft ? 8 : null,
            right: alignLeft ? null : 8,
            child: GestureDetector(
              onTap: onFavoriteToggle,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(
      double titleSize, double subtitleSize, double lessonSize) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title,
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          CustomText(
            text: subtitle,
            fontSize: subtitleSize,
            maxLines: 2,
            color: Colors.grey,
          ),
          const Spacer(),
          CustomText(
            text: lesson,
            fontSize: lessonSize,
            maxLines: 1,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
