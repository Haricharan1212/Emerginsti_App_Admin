import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'video_player_screen.dart' as video_player_screen;
import 'enlarged_video.dart' as enlarged_video;
import 'package:video_player/video_player.dart';

class Videos extends StatefulWidget {
  List<String> array;
  String alertDocID;
  String url;
  Videos(
      {Key? key,
      required this.array,
      required this.alertDocID,
      required this.url})
      : super(key: key);

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
                      removeUserID(widget.alertDocID);
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
                            return enlarged_video.EnlargedVideo(
                                widget.array[index], widget.url);
                          }));
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.topCenter,
                            child: video_player_screen.VideoPlayerScreen(
                                widget.url)))),
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

Future<void> removeUserID(String docID) async {
  CollectionReference logging =
      FirebaseFirestore.instance.collection("logging");
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  DocumentSnapshot docSnapshot = await users.doc(docID).get();
  await logging.add({
    'name': docSnapshot["name"],
    'email': docSnapshot["email"],
    'latitude': docSnapshot["latitude"],
    'longitude': docSnapshot["longitude"],
    'time_now': docSnapshot["time_now"]
  });
  users.doc(docID).delete();
}
