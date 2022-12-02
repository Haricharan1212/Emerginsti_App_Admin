import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const url =
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

// function to start app building
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomeRoute(),
        '/videos': (context) => Videos(),
        // '/third': (context) => const ThirdRoute(),
      },
      // home: HomeRoute(),
    ),
  );
}

@override
class HomeRoute extends StatelessWidget {
  const HomeRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text("Alerts"),
          ),
          body: CustomScrollView(
            slivers: <Widget>[
              SliverFixedExtentList(
                itemExtent: MediaQuery.of(context).size.width * 0.8,
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.3,
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(30),
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              FlutterRingtonePlayer.playNotification();
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return Videos();
                              }));
                            },
                            child: Text("hi")),
                      ));
                }, childCount: 5),
              ),
            ],
          )),
    );
  }
}

@override
class Videos extends StatelessWidget {
  Videos({super.key});

  late VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text("CCTV Videos"),
          ),
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                  pinned: true,
                  expandedHeight: 50.0,
                  collapsedHeight: 100.0,
                  titleSpacing: 0.0,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Problem averted!")),
                  )),
              SliverFixedExtentList(
                itemExtent: 240.0,
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    color: Colors.grey,
                    child: Scaffold(
                        appBar: AppBar(title: Text("CCTV Camera ${index + 1}")),
                        body: InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return EnlargedVideo();
                              }));
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                alignment: Alignment.topCenter,
                                child: VideoPlayerScreen()))),
                  );
                }, childCount: 5),
              ),
            ],
          )),
    );
  }
}

@override
class EnlargedVideo extends StatelessWidget {
  EnlargedVideo({super.key});

  late VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text("CCTV Video"),
      ),
      body: Container(
          alignment: Alignment.center,
          color: Colors.grey,
          child: Scaffold(
              appBar: AppBar(title: Text("CCTV Camera")),
              body: VideoPlayerScreen())),
      bottomNavigationBar: ElevatedButton(
          child: const Text("View Other Cameras"),
          onPressed: () {
            Navigator.pop(context);
          }),
    ));
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(url,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));

    _initializeVideoPlayerFuture = _controller.initialize();

    _controller.setLooping(true);
    _controller.setVolume(0);
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _controller.play();
          // If the VideoPlayerController has finished initialization, use
          // the data it provides to limit the aspect ratio of the video.
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            // Use the VideoPlayer widget to display the video.
            child: VideoPlayer(_controller),
          );
        } else {
          // If the VideoPlayerController is still initializing, show a
          // loading spinner.
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
