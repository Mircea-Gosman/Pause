/**-----------------------------------------------------------
 * Module allowing to access location data
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'package:location/location.dart';

class LocationService {

  /// Module call
  static void setLocationAvailable() async{
    // Location service
    Location location = new Location();

    // Verify availability and permission
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return;
      }
    }

    // Real-Time location listener
    location.onLocationChanged().listen((LocationData currentLocation) {
      // TODO: Use current location
    });
  }
}