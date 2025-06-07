import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:speak_up/widgets/custom_text.dart';

class CardConVerSation extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String tag;
  final Color tagColor;
  final String? content;
  final VoidCallback? onTap;

  const CardConVerSation({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.tag,
    required this.tagColor,
    this.content,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const imageHeight = 230.0; // Fixed height as per your request
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Ink(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: Colors.white,
        ),
        child: InkWell(
          onTap: onTap, // Null-safe, InkWell handles null automatically
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: imageHeight,
                      fit: BoxFit.cover,
                      memCacheHeight: (imageHeight *
                              MediaQuery.of(context).devicePixelRatio)
                          .toInt(),
                      memCacheWidth: (screenWidth *
                              MediaQuery.of(context).devicePixelRatio)
                          .toInt(),
                      fadeInDuration: const Duration(milliseconds: 300),
                      placeholder: (context, url) => const SizedBox(
                        height: imageHeight,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => const SizedBox(
                        height: imageHeight,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4)),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 60,
                      child: CustomText(
                        text: title,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Roboto',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (content != null && content!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: CustomText(
                          text: content!,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Roboto',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
