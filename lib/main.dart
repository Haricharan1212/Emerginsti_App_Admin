import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';

// function to start app building
void main() {
  runApp(
    MaterialApp(
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeRoute(),
        '/second': (context) => MyApp(),
        // '/third': (context) => const ThirdRoute(),
      },
      home: MyApp(),
    ),
  );
}

@override
class HomeRoute extends StatelessWidget {
  HomeRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text("Admin Side"),
            ),
            body: Container(
                width: MediaQuery.of(context).size.width * 1.0,
                height: MediaQuery.of(context).size.height * 0.3,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/second');
                    },
                    child: Text("Hi"),
                  ),
                ))));
  }
}

@override
class MyApp extends StatelessWidget {
  MyApp({super.key});

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
              // const SliverAppBar(
              //   pinned: true,
              //   expandedHeight: 100.0,
              //   flexibleSpace: FlexibleSpaceBar(
              //     title: Text('CCTV Cameras'),
              //   ),
              // ),
              // SliverGrid(
              //   gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              //     maxCrossAxisExtent: 200.0,
              //     mainAxisSpacing: 10.0,
              //     crossAxisSpacing: 10.0,
              //     childAspectRatio: 4.0,
              //   ),
              //   delegate: SliverChildBuilderDelegate(
              //     (BuildContext context, int index) {
              //       return Container(
              //         alignment: Alignment.center,
              //         // color: Colors.teal[100 * (index % 9)],
              //         child: Image.asset("assets/images/img1.jpg"),
              //       );
              //     },
              //     childCount: 5,
              //   ),
              // ),
              SliverFixedExtentList(
                itemExtent: 240.0,
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return Container(
                      alignment: Alignment.center,
                      color: Colors.grey,
                      child: Scaffold(
                        appBar: AppBar(title: Text("CCTV Camera ${index + 1}")),
                        body: MaterialApp(home: VideoPlayerScreen()),
                      ));
                }, childCount: 5),
              ),
            ],
          )

          // Image.asset("assets/images/img1.jpg")
          // VideoPlayer(VideoPlayerController.asset('http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4~')),
          ),
    );
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

    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
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

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Wrap the play or pause in a call to `setState`. This ensures the
      //     // correct icon is shown.
      //     setState(() {
      //       // If the video is playing, pause it.
      //       // If the video is paused, play it.
      //       _controller.play();
      //     });
      //   },
      //   // Display the correct icon depending on the state of the player.
      //   child: Icon(
      //     _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
      //   ),
      // ),
    );
  }
}

Future<String> readJson() async {
  final String response = await rootBundle.loadString('input_data.json');
  final data = await json.decode(response);
  return data;
}
