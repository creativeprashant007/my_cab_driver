import 'package:maps_toolkit/maps_toolkit.dart';

class MapKitHelper {
  static double getMarkerRotaion({
    double? sourceLat,
    double? sourceLng,
    double? destLat,
    double? destLng,
  }) {
    var rotation = SphericalUtil.computeHeading(
      LatLng(sourceLat!, sourceLng!),
      LatLng(
        destLat!,
        destLng!,
      ),
    );
    return rotation.toDouble();
  }
}
