import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/classes/question.dart';
import 'package:study_app/utils/colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeTutorial extends StatefulWidget {
  final Question question;
  final int totalQuestions;
  final int index;
  const YoutubeTutorial({
    super.key,
    required this.question,
    required this.totalQuestions,
    required this.index,
  });

  @override
  State<YoutubeTutorial> createState() => _YoutubeTutorialState();
}

class _YoutubeTutorialState extends State<YoutubeTutorial> {
  late YoutubePlayerController _controller;
  String url = "https://www.youtube.com/watch?v=0sacQ4oo-P0";

  String? extractYouTubeId(String url) {
    final regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:watch\?(?:.*&)?v=|embed\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  List<Subtitle> subtitle = [
    Subtitle(start: 2, end: 10, text: "Animated Contatiner Widget in Flutter"),
    // subtitle start at 2 second and end at 10 second
    Subtitle(start: 10, end: 20, text: "You can add your custom subtitle"),
    Subtitle(start: 20, end: 100, text: ""),
    // add mor subtitle as your requirement
  ];
  String subtitleText = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final videoId = extractYouTubeId(url);
    _controller = YoutubePlayerController(
        initialVideoId: videoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          forceHD: true,
        ))
      ..addListener(_onPlayStateChange);
  }

  void _onPlayStateChange() {
    if (_controller.value.playerState == PlayerState.playing) {
      final currentTime = _controller.value.position.inSeconds;
      final currentSubtitle = subtitle.firstWhere((subtitle) =>
          currentTime >= subtitle.start && currentTime <= subtitle.end);
      setState(() {
        subtitleText = currentSubtitle.text;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    // reset orientation on dispose (While pressing the back button)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _listener() {
    if (_controller.value.isFullScreen) {
      // set to landscape and hide system overlays when entering fullscreen
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      // set back to portrait and show overlays when exit from fullscreen
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        progressIndicatorColor: Colors.amber,
        bottomActions: [
          const CurrentPosition(),
          const ProgressBar(
            isExpanded: true,
          ),
          const RemainingDuration(),
          const PlaybackSpeedButton(),
          FullScreenButton(
            controller: _controller,
          ),
        ],
        onReady: _listener,
      ),
      builder: (context, player) => Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: blueGradientColor,
              ),
            ),
            centerTitle: true,
            title: Text(
              "Quick Tutorial",
              style: GoogleFonts.raleway(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE0F8E9), // very light green
                      Color(0xFFB2F2BB), // pale green
                      Color(0xFF90EE90), // light green (standard)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Question ${widget.index + 1}/${widget.totalQuestions}",
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      widget.question.text,
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              player,
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 190),
                child: Text(
                  subtitleText,
                  style: const TextStyle(fontSize: 17, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Subtitle {
  final int start;
  final int end;
  final String text;

  Subtitle({required this.start, required this.end, required this.text});
}
