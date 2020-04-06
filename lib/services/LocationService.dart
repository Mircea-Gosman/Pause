import 'package:location/location.dart';

class LocationService {

  // TODO: If needs arrise, make this into an instance method
  static void setLocationAvailable() async{
    Location location = new Location();

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