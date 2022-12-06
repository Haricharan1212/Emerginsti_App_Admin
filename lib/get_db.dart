import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

Future<Map<dynamic, dynamic>> getDocs(int i) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection("users")
      .orderBy("time_now", descending: true)
      .get();

  Map<dynamic, dynamic> docVal =
      await json.decode(json.encode(querySnapshot.docs[i].data()));
  docVal['docID'] = querySnapshot.docs[i].id;
  return docVal;
}

Future<int?> getDocsLen() async {
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection("users").get();

  return querySnapshot.docs.length;
}
