import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetail {
  String? pickupAddress;
  String? destinationAddress;
  LatLng? pickup;
  LatLng? destination;
  String? rideId;
  String? paymentMethod;
  String? riderName;
  String? riderPhone;

  TripDetail({
    this.pickupAddress,
    this.destinationAddress,
    this.pickup,
    this.destination,
    this.rideId,
    this.paymentMethod,
    this.riderName,
    this.riderPhone,
  });
}
