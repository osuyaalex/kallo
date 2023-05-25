import 'package:permission_handler/permission_handler.dart';
import 'dart:math' show cos, sqrt, asin;


class Functions{

   requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      return;
    } else if (status.isDenied) {
      return;
    } else if (status.isPermanentlyDenied) {
      return;
    }
  }

    double calculateDistance(String lat1, String lon1, String lat2, String lon2){
      try {
        double lati1 = double.parse(lat1);
        double lati2 = double.parse(lat2);
        double long1 = double.parse(lon1);
        double long2 = double.parse(lon2);

        const p = 0.017453292519943295; // 0.017453292519943295 radians = 1 degree
        final a = 0.5 -
            cos((lati2 - lati1) * p) / 2 +
            cos(lati1 * p) *
                cos(lati2 * p) *
                (1 - cos((long2 - long1) * p)) /
                2;
        return 12742 * asin(sqrt(a)) * 0.621371; // 12742 = 2 * 6371 (mean radius of Earth in km), 0.621371 = conversion factor from km to miles
      } catch (e) {
        print('Error parsing input strings: ${e.toString()}');
        return 0.0;
      }
}
}