import 'package:maps_launcher/maps_launcher.dart';

void openMap(double lat, double lon) async {
  MapsLauncher.launchCoordinates(lat, lon);
}
