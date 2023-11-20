import 'dart:async';

import 'dart:io';

import 'package:cab_driver/constants/brand_colors.dart';
import 'package:cab_driver/helpers/helper_methods.dart';
import 'package:cab_driver/helpers/map_kit_helper.dart';
import 'package:cab_driver/model/trip_detail_model.dart';
import 'package:cab_driver/widgets/TaxiOutlineButton.dart';
import 'package:cab_driver/widgets/payment_dialouge.dart';
import 'package:cab_driver/widgets/progress_dialog_cust.dart';
import 'package:cab_driver/widgets/taxi_button.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global_variables.dart';

class NewTripPage extends StatefulWidget {
  static const String id = 'new-trip-page';

  final TripDetail tripDetail;

  const NewTripPage({
    Key? key,
    required this.tripDetail,
  }) : super(key: key);

  @override
  _NewTripPageState createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  GoogleMapController? rideMapController;
  Completer<GoogleMapController> _controller = Completer();
  double mapPaddingBottom = 0;
  Timer? timer;
  int durationCounter = 0;
  var geoLocator = Geolocator();
  var locationOptions =
      LocationSettings(accuracy: LocationAccuracy.bestForNavigation);
  BitmapDescriptor? movingMarkerIcon;
  String durationString = "updating time....";
  String bottonTitle = "ARRIVED";
  Color bottonColor = BrandColors.colorGreen;

  bool isRequestingDirection = false;
  void createMarker() {
    if (movingMarkerIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
        context,
        size: Size(2, 2),
      );
      BitmapDescriptor.fromAssetImage(
        imageConfiguration,
        Platform.isIOS
            ? 'assets/images/car_ios.png'
            : 'assets/images/car_android.png',
      ).then((icon) {
        movingMarkerIcon = icon;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    acceptiTrip();
    super.initState();
  }

  void setupPositionLocator() async {
    var currentLatLng =
        LatLng(currentPosition!.latitude, currentPosition!.longitude);
    var pickupLatLng = widget.tripDetail.pickup;
    await getDirection(currentLatLng, pickupLatLng!);
    // Position position = await Geolocator.getCurrentPosition(
    //   desiredAccuracy: LocationAccuracy.best,
    // );
    // currentPosition = position;
    // LatLng pos = LatLng(position.latitude, position.longitude);
    // CameraPosition cameraPosition = new CameraPosition(target: pos, zoom: 17);
    // rideMapController!
    //     .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // print('we are her man go to fetch address');
  }

  Set<Marker> _markers = Set<Marker>();
  Set<Circle> _circles = Set<Circle>();
  Set<Polyline> _polyLines = Set<Polyline>();
  List<LatLng> polyLineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Position? myPosition;
  String status = "accepted";
  void getLocationUpgates() {
    LatLng oldPosition = LatLng(0, 0);
    ridePositionStream =
        Geolocator.getPositionStream().listen((Position position) {
      myPosition = position;
      currentPosition = position;
      LatLng pos = LatLng(position.latitude, position.longitude);
      currentPosition = position;
      var rotation = MapKitHelper.getMarkerRotaion(
        sourceLat: oldPosition.latitude,
        sourceLng: oldPosition.longitude,
        destLat: pos.latitude,
        destLng: pos.longitude,
      );
      Marker movingMarker = Marker(
        markerId: MarkerId("moving"),
        position: pos,
        rotation: rotation,
        icon: movingMarkerIcon!,
        infoWindow: InfoWindow(title: "Current Location"),
      );
      setState(() {
        CameraPosition cp = CameraPosition(target: pos, zoom: 17);
        rideMapController!.animateCamera(CameraUpdate.newCameraPosition(cp));
        _markers.removeWhere((marker) => marker.markerId.value == "moving");
        _markers.add(movingMarker);
      });
      oldPosition = pos;
      updateTripDetails();
    });
  }

  void updateTripDetails() async {
    if (!isRequestingDirection) {
      isRequestingDirection = true;
      if (myPosition == null) {
        return;
      }
      var positionLatLng = LatLng(myPosition!.latitude, myPosition!.longitude);
      LatLng destinationLatLng;
      if (status == "accepted") {
        destinationLatLng = widget.tripDetail.pickup!;
      } else {
        destinationLatLng = widget.tripDetail.destination!;
      }
      var directionDetails = await HelperMethods.getDirectionDetaiils(
        positionLatLng,
        destinationLatLng,
      );
      if (directionDetails != null) {
        print("here is duration text${directionDetails.durationText}");
        setState(() {
          durationString = directionDetails.durationText!;
        });
      }
      isRequestingDirection = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    createMarker();
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(top: 150, bottom: mapPaddingBottom),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: googlePlex,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            compassEnabled: true,
            circles: _circles,
            markers: _markers,
            polylines: _polyLines,
            // trafficEnabled: true,
            onMapCreated: (controller) async {
              _controller.complete(controller);
              rideMapController = controller;

              setState(() {
                mapPaddingBottom = Platform.isIOS ? 255 : 260;
              });
              var currentLatLng =
                  LatLng(currentPosition!.latitude, currentPosition!.longitude);
              var pickupLatLng = widget.tripDetail.pickup;

              await getDirection(currentLatLng, pickupLatLng!);
              getLocationUpgates();
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: Platform.isIOS ? 280 : 250,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ]),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$durationString",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Brand-Bold",
                        color: BrandColors.colorAccentPurple,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${widget.tripDetail.riderName}",
                          style:
                              TextStyle(fontSize: 22, fontFamily: "Brand-Bold"),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.call),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    tripDetails(
                        image: "assets/images/pickicon.png",
                        location: "${widget.tripDetail.pickupAddress}"),
                    SizedBox(
                      height: 25,
                    ),
                    tripDetails(
                        image: "assets/images/desticon.png",
                        location: "${widget.tripDetail.destinationAddress}"),
                    SizedBox(
                      height: 25,
                    ),
                    TexiButton(
                      title: "$bottonTitle",
                      callback: () async {
                        if (status == "accepted") {
                          status = "arrived";
                          rideRef!.child("status").set(("arrive"));
                          setState(() {
                            bottonTitle = "START TRIP";
                            bottonColor = BrandColors.colorAccentPurple;
                          });
                          HelperMethods.showProfressDialog(context);
                          await getDirection(widget.tripDetail.pickup!,
                              widget.tripDetail.destination!);
                          Navigator.of(context).pop();
                        } else if (status == "arrived") {
                          status = "ontrip";
                          rideRef!.child("status").set("ontrip");
                          setState(() {
                            bottonTitle = "END TRIP";
                            bottonColor = Colors.red;
                            startTimer();
                          });
                        } else if (status == "ontrip") {
                          endTrip();
                        }
                      },
                      color: bottonColor,
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    ));
  }

  Row tripDetails({String? image, String? location}) {
    return Row(
      children: [
        Image.asset(
          "$image",
          height: 16,
          width: 16,
        ),
        SizedBox(
          width: 18,
        ),
        Expanded(
          child: Text(
            "$location",
            style: TextStyle(
              fontSize: 18,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }

  void acceptiTrip() {
    String rideId = widget.tripDetail.rideId!;
    rideRef = FirebaseDatabase.instance.ref().child("rideRequest/$rideId");
    rideRef!.child("status").set("accepted");
    rideRef!.child("driver_name").set(currentDricerInfo!.fullName);
    rideRef!
        .child("car_details")
        .set("${currentDricerInfo!.carColor}-${currentDricerInfo!.carModel}");
    rideRef!.child("driver_phone").set(currentDricerInfo!.phone);
    rideRef!.child("driver_id").set(currentDricerInfo!.id);
    Map locationMap = {
      "latitude": currentPosition!.latitude.toString(),
      "lognitude": currentPosition!.longitude.toString()
    };
    rideRef!.child("driver_location").set(locationMap);
    DatabaseReference historyRefrence = FirebaseDatabase.instance
        .ref()
        .child("drivers/${currentFirebaseUser!.uid}/history/$rideId");
    historyRefrence.set("true");
  }

  Future<void> getDirection(LatLng pickLatLng, LatLng destinationLatLng) async {
    showDialog(
      context: context,
      builder: (context) => ProgressDialogCust(
        status: 'Please Wait',
      ),
    );
    var thisDetails =
        await HelperMethods.getDirectionDetaiils(pickLatLng, destinationLatLng);

    Navigator.of(context).pop();
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline('${thisDetails!.encodedPoints}');
    polyLineCoordinates.clear();
    if (results.isNotEmpty) {
      results.forEach((points) {
        polyLineCoordinates.add(LatLng(points.latitude, points.longitude));
      });
    }
    _polyLines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyId'),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polyLineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      _polyLines.add(polyline);
    });

    LatLngBounds bounds;
    if (pickLatLng.latitude > destinationLatLng.latitude &&
        pickLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickLatLng);
    } else if (pickLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, pickLatLng.longitude));
    } else if (pickLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickLatLng.longitude),
          northeast: LatLng(pickLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds = LatLngBounds(
        southwest: pickLatLng,
        northeast: destinationLatLng,
      );
    }
    rideMapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    _markers.clear();
    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId(
        'pickup',
      ),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: BrandColors.colorGreen,
    );
    Circle destinationCircle = Circle(
      circleId: CircleId(
        'destination',
      ),
      strokeColor: Colors.red,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: BrandColors.colorAccentPurple,
    );

    _circles.clear();
    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });
  }

  void startTimer() {
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCounter++;
    });
  }

  void endTrip() async {
    timer!.cancel();
    HelperMethods.showProfressDialog(context);
    var currentLatLng = LatLng(myPosition!.latitude, myPosition!.longitude);
    var directionDetails = await HelperMethods.getDirectionDetaiils(
        widget.tripDetail.pickup!, currentLatLng);
    Navigator.pop(context);
    int fares = HelperMethods.estimateFares(directionDetails!, durationCounter);
    rideRef!.child("fares").set(fares.toString());
    rideRef!.child("status").set("ended");
    ridePositionStream!.cancel();
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CollectPayment(
              paymentMethod: "${widget.tripDetail.paymentMethod}",
              fares: fares);
        });
    topUpEarnngs(fares);
  }

  void topUpEarnngs(int fares) {
    DatabaseReference earningrefrence = FirebaseDatabase.instance
        .ref()
        .child("drivers/${currentFirebaseUser!.uid}/earnings");
    earningrefrence.once().then((DatabaseEvent snapshot) {
      if (snapshot.snapshot.value != null) {
        double oldEarnings = double.parse(snapshot.snapshot.value.toString());
        double adjuctedFares = ((fares.toDouble()) * 0.85) + oldEarnings;
        earningrefrence.set(adjuctedFares.toStringAsFixed(2));
      } else {
        double adjuctedFares = ((fares.toDouble()) * 0.85);
        earningrefrence.set(adjuctedFares.toStringAsFixed(2));
      }
    });
  }
}
