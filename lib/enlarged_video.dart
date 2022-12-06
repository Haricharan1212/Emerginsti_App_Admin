import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'video_player_screen.dart' as video_player_screen;

@override
class EnlargedVideo extends StatelessWidget {
  late VideoPlayerController controller;
  String text;
  String url;

  EnlargedVideo(this.text, this.url) {
    super.key;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text("CCTV Camera"),
      ),
      body: Container(
          alignment: Alignment.center,
          color: Colors.grey,
          child: Scaffold(
              appBar: AppBar(title: Text(this.text)),
              body: video_player_screen.VideoPlayerScreen(this.url))),
      bottomNavigationBar: ElevatedButton(
          child: const Text("View Other Cameras"),
          onPressed: () {
            Navigator.pop(context);
          }),
    ));
  }
}
