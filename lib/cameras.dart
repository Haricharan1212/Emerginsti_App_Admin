import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class CameraInfo {
  static Future<List<List<String>>> returnCameraDetails() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("camera details").get();

    List<List<String>> cameraDetails = [];

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      Map<dynamic, dynamic> cameraDetailsMap =
          await json.decode(json.encode(querySnapshot.docs[i].data()));

      cameraDetails.add([
        cameraDetailsMap["ip"].toString() +
            "  " +
            cameraDetailsMap["location"].toString(),
        cameraDetailsMap["lat"].toString(),
        cameraDetailsMap["lng"].toString()
      ]);
    }
    return cameraDetails;
  }
}

List<List<String>> cameraDetails = [[]];

void cameraCall() async {
  cameraDetails = await CameraInfo.returnCameraDetails();
}
