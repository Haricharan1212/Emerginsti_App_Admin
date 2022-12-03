import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'cameras.dart' as camera_data;
import 'geo_sorter.dart' as geo_sorter;

const url =
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

// function to start app building
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  camera_data.cameraCall();
  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
      },
    ),
  );
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
  int userCount = 0;
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 1),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeRoute())));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Image.asset(
        'assets/images/splashscreen.png',
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

class HomeRoute extends StatefulWidget {
  @override
  _MyHomeRouteState createState() => _MyHomeRouteState();
}

class _MyHomeRouteState extends State<HomeRoute> {
  @override
  void initState() {
    super.initState();
    final docRef = FirebaseFirestore.instance.collection("users");
    docRef.snapshots().listen((event) async {
      FlutterRingtonePlayer.playNotification();
      setState(() {});
    });
  }

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
                childCount: 10,
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
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return FutureBuilder(
                                  future: getDocs(index),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return Videos(
                                          array: geo_sorter.returnIndices(
                                              snapshot.data?["latitude"],
                                              snapshot.data?["longitude"],
                                              camera_data.cameraDetails));
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                            color: Colors.white),
                                      );
                                    }
                                  },
                                );
                              }));
                            },
                            child: FutureBuilder(
                              future: getDocs(index),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Text(
                                      textAlign: TextAlign.center,
                                      "${(snapshot.data?["name"])}\n${(snapshot.data?["roll_no"])}\n${(snapshot.data?["time_now"])}\nLatitude: ${snapshot.data?["latitude"]}  Longitude: ${snapshot.data?["longitude"]}");
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white),
                                  );
                                }
                              },
                            ),
                          )));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<int?> getDocsLen() async {
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection("users").get();

  return querySnapshot.docs.length;
}

Future<Map<dynamic, dynamic>> getDocs(int i) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection("users")
      .orderBy("time_now", descending: true)
      .get();

  Map<dynamic, dynamic> docVal =
      await json.decode(json.encode(querySnapshot.docs[i].data()));
  return docVal;
}

class Videos extends StatefulWidget {
  List<String> array;

  Videos({Key? key, required this.array}) : super(key: key);

  @override
  _Videos createState() => _Videos();
}

class _Videos extends State<Videos> {
  @override
  void initState() {
    super.initState();
  }

  late VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text("CCTV Videos"),
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
                    child: const Text("Problem averted!")),
              )),
          SliverFixedExtentList(
            itemExtent: 240.0,
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              return Container(
                alignment: Alignment.center,
                color: Colors.grey,
                child: Scaffold(
                    appBar: AppBar(title: Text("${widget.array[index]}")),
                    body: InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return EnlargedVideo(widget.array[index]);
                          }));
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.topCenter,
                            child: const VideoPlayerScreen()))),
              );
            }, childCount: 5),
          ),
        ],
      ),
      floatingActionButton: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.blue,
        child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
    ));
  }
}

@override
class EnlargedVideo extends StatelessWidget {
  EnlargedVideo(this.text) {
    super.key;
  }

  late VideoPlayerController controller;
  String text;

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
              body: const VideoPlayerScreen())),
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
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
