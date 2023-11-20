import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'model/driver.dart';

firebase.User? currentFirebaseUser;
String mapKey = "AIzaSyBEnYVcxOEaejEzT6UyG8l8n5EZ2mT9C1I";

CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14,
);
DatabaseReference? tripRequestRef;
DatabaseReference? rideRef;
StreamSubscription<Position>? hoomeTabPostionStream;
StreamSubscription<Position>? ridePositionStream;
var assetAudioPlayer = AssetsAudioPlayer();
Position? currentPosition;
Driver? currentDricerInfo;
