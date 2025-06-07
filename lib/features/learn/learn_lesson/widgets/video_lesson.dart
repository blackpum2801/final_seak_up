import 'package:flutter/material.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/features/learn/learn_lesson/widgets/custom_button.dart';
import 'package:speak_up/widgets/custom_text.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoLesson extends StatefulWidget {
  final String videoUrl;
  final VoidCallback onNext;
  final List<VideoInfo> relatedVideos;
  final bool showNextButton;
  const VideoLesson({
    super.key,
    required this.videoUrl,
    required this.onNext,
    required this.relatedVideos,
    this.showNextButton = true,
  });

  @override
  State<VideoLesson> createState() => _VideoLessonState();
}

class _VideoLessonState extends State<VideoLesson> {
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    _initializePlayer(widget.videoUrl);
  }

  void _initializePlayer(String url) {
    final videoId = YoutubePlayer.convertUrlToId(url);
    if (videoId == null) {
      debugPrint("❌ Không thể lấy ID video từ URL: $url");
      return;
    }
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  void _changeVideo(String newUrl) {
    final videoId = YoutubePlayer.convertUrlToId(newUrl);
    if (videoId == null) {
      debugPrint("❌ Không thể lấy ID video từ URL: $newUrl");
      return;
    }
    _youtubeController.load(videoId);
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.showNextButton
          ? null
          : AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: CustomText(
                        text: "Xem ngay video để học thêm",
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: CustomText(
                        text: "về âm này nhé!",
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              YoutubePlayerBuilder(
                player: YoutubePlayer(
                  controller: _youtubeController,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.red,
                ),
                builder: (context, player) {
                  return Column(
                    children: [
                      SizedBox(height: 230, child: player),
                      const SizedBox(height: 30),
                      _buildRelatedVideos(),
                    ],
                  );
                },
              ),
              if (widget.showNextButton)
                NextButton(
                  onPressed: widget.onNext,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedVideos() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.relatedVideos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          final video = widget.relatedVideos[index];
          return GestureDetector(
            onTap: () => _changeVideo(video.videoUrl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 100,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                      bottom: Radius.circular(14),
                    ),
                    child: Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    video.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class VideoInfo {
  final String title;
  final String videoUrl;
  final String thumbnailUrl;

  VideoInfo({
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
  });
}
