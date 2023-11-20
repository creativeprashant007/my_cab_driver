import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart' as audio;
import 'package:cab_driver/global_variables.dart';
import 'package:cab_driver/model/trip_detail_model.dart';
import 'package:cab_driver/widgets/notification_dialog.dart';
import 'package:cab_driver/widgets/progress_dialog_cust.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class pushNotificationService {
  // final FirebaseMessaging fcm = FirebaseMessaging.instance;
  Future initialize(context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      var rideId = getRideId(message!.data);
      fetchRideInfo(rideId!, context);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      var rideId = getRideId(message.data);
      fetchRideInfo(rideId!, context);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      var rideId = getRideId(message.data);
      fetchRideInfo(rideId!, context);
    });
    FirebaseMessaging.onBackgroundMessage((message) {
      return _firebaseMessagingBackgroundHandler(message, context);
    });
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message, context) async {
    var rideId = getRideId(message.data);
    fetchRideInfo(rideId!, context);
  }

  Future<void> getToken() async {
    print("we are here");
    String? token = await FirebaseMessaging.instance.getToken();
    print('token:$token');
    DatabaseReference tokenRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser!.uid}/token');
    tokenRef.set(token);
    FirebaseMessaging.instance.subscribeToTopic('allDrivers');
    FirebaseMessaging.instance.subscribeToTopic('allUsers');

    // return token!;
  }

  String? getRideId(Map<String, dynamic> message) {
    String? rideId;
    if (Platform.isAndroid) {
      rideId = message['ride_id'];
      print('rideId :$rideId');
    }
    return rideId;
  }

  void fetchRideInfo(String rideId, context) {
    print("inside dialog");
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return ProgressDialogCust(
            status: 'Fetching Details...',
          );
        });
    Future.delayed(Duration(seconds: 1));
    print('insideDD:$rideId');
    DatabaseReference rideRef =
        FirebaseDatabase.instance.reference().child('rideRequest/$rideId');
    rideRef.once().then((DatabaseEvent snapshot) {
      Navigator.of(context).pop();
      print("shapshot value${snapshot.snapshot.value}");
      if (snapshot.snapshot.value != null) {
        assetAudioPlayer.open(
          audio.Audio('assets/sounds/alert.mp3'),
        );
        assetAudioPlayer.play();

        double pickupLat = double.parse(
            (snapshot.snapshot.value as dynamic)['location']['latitude']
                .toString());
        double pickupLng = double.parse(
            (snapshot.snapshot.value as dynamic)['location']['longitude']
                .toString());
        String pickupAddress =
            (snapshot.snapshot.value as dynamic)['pickup_address'].toString();

        double destinationLat = double.parse(
            (snapshot.snapshot.value as dynamic)['destination']['latitude']
                .toString());
        double destinationLng = double.parse(
            (snapshot.snapshot.value as dynamic)['destination']['longitude']
                .toString());
        String destinationAddress =
            (snapshot.snapshot.value as dynamic)['destination_address']
                .toString();
        String paymentMethod =
            (snapshot.snapshot.value as dynamic)['payment_method'].toString();
        String riderName =
            (snapshot.snapshot.value as dynamic)['rider_name'].toString();
        String riderPhone =
            (snapshot.snapshot.value as dynamic)['rider_phone'].toString();

        TripDetail tripDetail = TripDetail();
        tripDetail.rideId = rideId;
        tripDetail.pickupAddress = pickupAddress;
        tripDetail.destinationAddress = destinationAddress;
        tripDetail.pickup = LatLng(pickupLat, pickupLng);
        tripDetail.destination = LatLng(destinationLat, destinationLng);
        tripDetail.paymentMethod = paymentMethod;
        tripDetail.riderName = riderName;
        tripDetail.riderPhone = riderPhone;

        print('pickupaddress :${tripDetail.pickupAddress}');
        print('pickupaddress :${tripDetail.destinationAddress}');

        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return NotificationDialog(tripDetail: tripDetail);
            });
      }
    });
  }
}
