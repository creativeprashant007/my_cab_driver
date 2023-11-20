import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseServices {
  // Initialize Firebase.
  FirebaseApp? defaultApp;
  FirebaseServices._internal() {
    print("\n\nFirebase Service Internal Called....");
    // initialiseFirebase();
  }

  static final FirebaseServices _instance = FirebaseServices._internal();

  static FirebaseServices get instance => _instance;

  FirebaseMessaging? messaging;
  NotificationSettings? settings;
  String? firebaseToken;

  initialiseFirebase() {
    // defaultApp = await Firebase.initializeApp();
    return Firebase.initializeApp();
  }

  initFirebaseMessaging() {
    return FirebaseMessaging.instance;
  }

  initFirebaseNotificationSettings() {
    return messaging!.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
  }

  setOptions() {
    messaging!.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  getFCMToken() async {
    // SharedPreferencesHelper.setStringValue(
    //     SharedPreferenceKeys.FCM_TOKEN!, await messaging!.getToken());

    return messaging!.getToken();
  }

  onMessage(RemoteMessage message) {
    print("here it is");
    RemoteNotification notification = message.notification!;
    AndroidNotification android = AndroidNotification();
    AppleNotification apple = AppleNotification();

    print("\nOn Message Service....\n");
    print("count processing");
    // Get.put(MessagesController()).getNotificationMessages();
    // Get.put(MainPageController()).currentTabIndex.value = 2;
  }
}

onMessageOpenedApp(RemoteMessage message) {
  RemoteNotification notification = message.notification!;
  AndroidNotification android = message.notification!.android!;
  var payload = message.data;
  print("count processing");
}
