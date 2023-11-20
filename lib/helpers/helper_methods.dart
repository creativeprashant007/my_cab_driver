import 'dart:math';

import 'package:cab_driver/helpers/request_helpers.dart';
import 'package:cab_driver/model/directions_details.dart';
import 'package:cab_driver/model/history.dart';
import 'package:cab_driver/provider/data_provider.dart';
import 'package:cab_driver/widgets/progress_dialog_cust.dart';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';

import '../global_variables.dart';

class HelperMethods {
  // static void getCurrentUserInfo() async {
  //   currentFirebaseUser = firebase.FirebaseAuth.instance.currentUser!;
  //   String userId = currentFirebaseUser!.uid;
  //   DatabaseReference databaseReference =
  //       FirebaseDatabase.instance.ref().child('users/$userId');
  //   databaseReference.once().then((DataSnapshot snapshot) {
  //     if (snapshot.value != null) {
  //       currentUserInfo = User.fromSnapsot(snapshot);
  //       print(
  //           'her is my full ianem +++++++++++++++++++++++|||||||||||||||||||||||||||||||||||');
  //       print('my name is${currentUserInfo!.fullName}');
  //     }
  //   });
  // }

  // static Future<String> findCordinateAddress(
  //   double lat,
  //   double lng,
  //   BuildContext context,
  // ) async {
  //   print('insider find co func');
  //   String placeAddress = "";
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult != ConnectivityResult.mobile &&
  //       connectivityResult != ConnectivityResult.wifi) {
  //     return placeAddress;
  //   }
  //   String url =
  //       "https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat},${lng}&key=${mapKey}";

  //   // String url =
  //   //     "https://maps.googleapis.com/maps/api/geocode/json?latlng=27.657522,85.33301&key=${mapKey}";

  //   var response = await RequestHelper.getRequest(url);
  //   print('here s the latest response $response');
  //   if (response != "failed") {
  //     // ignore: unnecessary_statements
  //     placeAddress = response['results'][0]['formatted_address'];
  //     Address pickupAddress = new Address(
  //       latitude: lat,
  //       longitude: lng,
  //       placeName: placeAddress,
  //       placeId: '',
  //       placeFormattedAddress: '',
  //     );
  //     Provider.of<AppData>(context, listen: false)
  //         .updatePickupAddress(pickupAddress);
  //   }
  //   return placeAddress;
  // }

  static Future<DirectionDetails?> getDirectionDetaiils(
      LatLng startPosition, LatLng endPosition) async {
    var url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=${mapKey}";
    var response = await RequestHelper.getRequest(url);
    print('here is helper method response');
    print(response);
    if (response == "failed") {
      print('failed here');
      return null;
    } else {
      print('success here');

      DirectionDetails directionDetails = DirectionDetails();
      directionDetails.durationText =
          response['routes'][0]['legs'][0]['duration']['text'];
      directionDetails.durationValue =
          response['routes'][0]['legs'][0]['duration']['value'];
      directionDetails.distanceText =
          response['routes'][0]['legs'][0]['distance']['text'];
      directionDetails.distanceValue =
          response['routes'][0]['legs'][0]['distance']['value'];
      directionDetails.encodedPoints =
          response['routes'][0]['overview_polyline']['points'];
      print('here is final data');
      print(response['routes'][0]['legs'][0]['duration']['text']);

      return directionDetails;
    }
  }

  static int estimateFares(DirectionDetails details, int durationValue) {
    //per kilomerter = Rs 20
    //base fare = 30
    //perminute = 5

    double baseFare = 16;
    double distanceFare = (details.distanceValue! / 1000) * 5;
    double timeFare = (durationValue / 60) * 2;
    double totalFare = baseFare + distanceFare + timeFare;
    return totalFare.truncate();
  }

  static double generateRandomNumber(int max) {
    var randomGenerator = Random();
    int ranInt = randomGenerator.nextInt(max);
    return ranInt.toDouble();
  }

  static void disableHomTabLocationUpdate() {
    hoomeTabPostionStream!.pause();
    Geofire.removeLocation(currentFirebaseUser!.uid);
  }

  static void enableHomTabLocationUpdates() {
    hoomeTabPostionStream!.resume();
    Geofire.setLocation(currentFirebaseUser!.uid, currentPosition!.latitude,
        currentPosition!.longitude);
  }

  static void showProfressDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return ProgressDialogCust(status: "Please Wait");
        });
  }

  static void getHistoryInfo({BuildContext? context}) {
    DatabaseReference earningInfo = FirebaseDatabase.instance
        .ref()
        .child("drivers/${currentFirebaseUser!.uid}/earnings");
    earningInfo.once().then((DatabaseEvent snapshot) {
      if (snapshot.snapshot.value != null) {
        String earnings = snapshot.snapshot.value.toString();
        Provider.of<AppData>(context!, listen: false).updateEarning(earnings);
      }
    });
    DatabaseReference historyRef = FirebaseDatabase.instance
        .ref()
        .child("drivers/${currentFirebaseUser!.uid}/history");
    historyRef.once().then((DatabaseEvent snapshot) {
      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.snapshot.value as Map;
        int tripCount = values.length;
        Provider.of<AppData>(context!, listen: false)
            .updateTripCount(tripCountTotal: tripCount.toString());
        List<String> tripHistoryKeys = [];
        values.forEach((key, value) {
          tripHistoryKeys.add(key);
        });
        Provider.of<AppData>(context, listen: false)
            .updateTripHistoryKeys(tripHistoryKeys);
        getHistoryData(context: context);
      }
    });
  }

  static getHistoryData({BuildContext? context}) {
    var keys = Provider.of<AppData>(context!, listen: false).tripHistoryKeys;
    for (String key in keys) {
      DatabaseReference historyRef =
          FirebaseDatabase.instance.ref().child("rideRequest/$key");
      historyRef.once().then((DatabaseEvent snapshot) {
        if (snapshot.snapshot.value != null) {
          var history = History.fromSnapShot(snapshot.snapshot);
          Provider.of<AppData>(context, listen: false)
              .updateTripHistory(history);
          print("history pickup ${history.pickup}");
        }
      });
    }
  }
}
