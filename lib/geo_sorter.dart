double findDistance(double lat1, double lat2, double lon1, double lon2) {
  double a = (1000 * (lat1 - lat2)) * (1000 * (lat1 - lat2)) +
      (1000 * (lon1 - lon2)) * (1000 * (lon1 - lon2));

  return a;
}

List<String> returnIndices(
    String latt, String lonn, List<List<String>> cameraDetails) {
  double lat = double.parse(latt);
  double lon = double.parse(lonn);

  cameraDetails.sort((a, b) =>
      (findDistance(lat, double.parse(a[1]), lon, double.parse(a[2])).compareTo(
          findDistance(lat, double.parse(b[1]), lon, double.parse(b[2])))));

  List<String> ans = [];

  for (int i = 0; i < cameraDetails.length; i++) {
    ans.add(cameraDetails[i][0]);
  }
  return ans;
}
