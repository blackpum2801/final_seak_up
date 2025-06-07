import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardCommunity extends StatelessWidget {
  final String logo;
  final String title;
  final String author;
  final String vocabulary;
  final int likes;
  final Color backgroundColor;
  final double width;
  final VoidCallback onTap;
  const CardCommunity({
    Key? key,
    required this.logo,
    required this.title,
    required this.author,
    required this.vocabulary,
    required this.likes,
    required this.backgroundColor,
    required this.onTap,
    this.width = 260,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              maxRadius: 35,
              minRadius: 35,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(logo, width: 40, height: 40),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'by $author',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Từ vựng: $vocabulary',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border,
                    color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$likes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
