// @dart=2.9

import 'dart:io';

import 'package:cab_driver/global_variables.dart';
import 'package:cab_driver/helpers/firebase_services.dart';
import 'package:cab_driver/helpers/push_notification_service.dart';
import 'package:cab_driver/provider/data_provider.dart';
import 'package:cab_driver/screens/login_page.dart';
import 'package:cab_driver/screens/main_page.dart';
import 'package:cab_driver/screens/new_trip_page.dart';
import 'package:cab_driver/screens/vehicle_info_page.dart';
import 'package:cab_driver/screens/regisration_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(message.data);
  print("Handling a background message: ${message.messageId}");

  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp(
  //     options: const FirebaseOptions(
  //   apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
  //   appId: '1:448618578101:ios:2bc5c1fe2ec336f8ac3efc',
  //   messagingSenderId: '448618578101',
  //   projectId: 'react-native-firebase-testing',
  // ));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FirebaseApp app = await Firebase.initializeApp(
    // name: 'db7',
    options: Platform.isIOS
        ? const FirebaseOptions(
            appId: '1:297855924061:ios:c6de2b69b03a5be8',
            apiKey: 'AIzaSyBEnYVcxOEaejEzT6UyG8l8n5EZ2mT9C1I',
            projectId: 'flutter-firebase-plugins',
            messagingSenderId: '589846735931',
            databaseURL: 'https://cab-rider-35e1c-default-rtdb.firebaseio.com',
          )
        : const FirebaseOptions(
            appId: '1:589846735931:android:d64a53fd3793d6e0c8c01e',
            apiKey: 'AIzaSyBEnYVcxOEaejEzT6UyG8l8n5EZ2mT9C1I',
            messagingSenderId: '297855924061',
            projectId: 'flutter-firebase-plugins',
            databaseURL: 'https://cab-rider-35e1c-default-rtdb.firebaseio.com',
          ),
  );
  FirebaseServices firebaseServices = FirebaseServices.instance;
  firebaseServices.defaultApp = await firebaseServices.initialiseFirebase();
  firebaseServices.messaging = await firebaseServices.initFirebaseMessaging();
  firebaseServices.settings =
      await firebaseServices.initFirebaseNotificationSettings();
  firebaseServices.defaultApp.setAutomaticDataCollectionEnabled(true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    firebaseServices.onMessage(message);
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
  currentFirebaseUser = await FirebaseAuth.instance.currentUser;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Car Driver',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Brand-Regular',
            visualDensity: VisualDensity.adaptivePlatformDensity),
        initialRoute: currentFirebaseUser == null ? LoginPage.id : MainPage.id,
        routes: {
          MainPage.id: (context) => MainPage(),
          LoginPage.id: (context) => LoginPage(),
          RegistrationPage.id: (context) => RegistrationPage(),
          VehicleInfo.id: (context) => VehicleInfo(),
          NewTripPage.id: (context) => NewTripPage(),
        },
      ),
    );
  }
}
