import 'dart:async';

import 'package:cab_driver/constants/brand_colors.dart';
import 'package:cab_driver/global_variables.dart';
import 'package:cab_driver/helpers/helper_methods.dart';
import 'package:cab_driver/helpers/push_notification_service.dart';
import 'package:cab_driver/model/driver.dart';
import 'package:cab_driver/widgets/availability_button.dart';
import 'package:cab_driver/widgets/confirm_sheet.dart';
import 'package:cab_driver/widgets/taxi_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  GoogleMapController? googleMapController;
  Completer<GoogleMapController> _controller = Completer();
  String? availabilityTitle = 'GO ONLINE';
  Color? availbilityColor = BrandColors.colorOrange;
  bool isAvailable = false;
  var geolocator = Geolocator();
  var locationOptions = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4);

  Future<dynamic> _callPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  void setupPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(target: pos, zoom: 17);
    googleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    print('we are her man go to fetch address');
    // String address = await HelperMethods.findCordinateAddress(
    //   position.latitude,
    //   position.longitude,
    //   context,
    // );

    // print('herei is the address${position.latitude} lon${position.longitude}');
    // print(address);
  }

  @override
  void initState() {
    // TODO: implement initState

    _callPermission();

    getCurrentDriverInfo();
    // fetchRideInfo(String rideId, context);
    HelperMethods.getHistoryInfo(context: context);
    super.initState();
  }

  void getCurrentDriverInfo() async {
    currentFirebaseUser = FirebaseAuth.instance.currentUser;
    pushNotificationService().getToken();

    pushNotificationService().initialize(context);
    DatabaseReference driverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers/${currentFirebaseUser!.uid}");
    driverRef.once().then((DatabaseEvent snapshot) {
      currentDricerInfo = Driver.fromSnapshot(snapshot.snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(top: 150),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          initialCameraPosition: googlePlex,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          compassEnabled: true,
          // trafficEnabled: true,
          onMapCreated: (controller) {
            _controller.complete(controller);
            googleMapController = controller;
            setState(() {
              setupPositionLocator();
            });
          },
        ),
        Container(
          height: 135,
          color: BrandColors.colorPrimary,
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AvailabilityButton(
                title: availabilityTitle!,
                color: availbilityColor!,
                callback: () {
                  showModalBottomSheet(
                      isDismissible: false,
                      context: context,
                      builder: (context) {
                        return ConfirmSheet(
                          title: !isAvailable ? 'GO ONLINE' : 'GO OFFLINE',
                          onPress: () {
                            if (!isAvailable) {
                              goOnline();
                              getLocationUpdate();
                              Navigator.of(context).pop();
                              setState(() {
                                availbilityColor = BrandColors.colorGreen;
                                availabilityTitle = 'GO OFFLINE';
                                isAvailable = true;
                              });
                            } else {
                              goOffline();
                              Navigator.of(context).pop();
                              setState(() {
                                availbilityColor = BrandColors.colorOrange;
                                availabilityTitle = 'GO ONLINE';
                                isAvailable = false;
                              });
                            }
                          },
                          subtitle: !isAvailable
                              ? 'You are about to become available to receive trip requests'
                              : 'You will stop receiving new trip request',
                        );
                      });
                  // goOnline();
                  // getLocationUpdate();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void goOnline() async {
    Geofire.initialize('driversAvailable');
    Geofire.setLocation(
      currentFirebaseUser!.uid,
      currentPosition!.latitude,
      currentPosition!.longitude,
    );
    tripRequestRef = FirebaseDatabase.instance
        .ref()
        .child('drivers/${currentFirebaseUser!.uid}/newtrip');
    tripRequestRef!.set('waiting');
    tripRequestRef!.onValue.listen((event) {});
  }

  void goOffline() async {
    Geofire.removeLocation(currentFirebaseUser!.uid);
    tripRequestRef!.onDisconnect();
    tripRequestRef!.remove();
    tripRequestRef = null;
  }

  void getLocationUpdate() {
    hoomeTabPostionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2,
      ),
    ).listen((position) {
      currentPosition = position;

      if (isAvailable) {
        Geofire.setLocation(
          currentFirebaseUser!.uid,
          position.latitude,
          position.longitude,
        );
      }
      LatLng pos = LatLng(position.latitude, position.longitude);
      CameraPosition cameraPosition = new CameraPosition(target: pos, zoom: 14);
      googleMapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    });
  }
}
