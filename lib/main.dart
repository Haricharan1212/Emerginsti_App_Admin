import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cameras.dart' as camera_data;
import 'geo_sorter.dart' as geo_sorter;
import 'videos.dart' as videos;
import 'get_db.dart' as get_db;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

const url =
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

int? len = 0;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  camera_data.cameraCall();

  len = await get_db.getDocsLen();

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
      len = await get_db.getDocsLen();
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
          // body: ListView(children: returnListWidgets(returnedIndices))

          body: ListView(
            itemExtent: MediaQuery.of(context).size.width * 0.8,
            children: [
              for (int index = 0; index < len!; index++)
                Container(
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
                                future: get_db.getDocs(index),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return videos.Videos(
                                        array: geo_sorter.returnIndices(
                                            snapshot.data?["latitude"],
                                            snapshot.data?["longitude"],
                                            camera_data.cameraDetails),
                                        alertDocID: snapshot.data?["docID"],
                                        url: url);
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
                            future: get_db.getDocs(index),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Text(
                                    textAlign: TextAlign.center,
                                    "${(snapshot.data?["name"])}\n${(snapshot.data?["email"])}\n${(snapshot.data?["time_now"])}\nLatitude: ${snapshot.data?["latitude"]}  Longitude: ${snapshot.data?["longitude"]}");
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white),
                                );
                              }
                            },
                          ),
                        )))
            ],
          )),
    );
  }
}
