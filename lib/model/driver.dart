import 'package:firebase_database/firebase_database.dart';

class Driver {
  String? fullName;
  String? email;
  String? phone;
  String? id;
  String? carModel;
  String? carColor;
  String? vehicleNumber;
  Driver({
    this.fullName,
    this.email,
    this.phone,
    this.id,
    this.carModel,
    this.carColor,
    this.vehicleNumber,
  });

  Driver.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    phone = (snapshot.value as dynamic)['phone'];
    email = (snapshot.value as dynamic)['email'];
    carColor = (snapshot.value as dynamic)["vehicle_details"]['car_color'];
    carModel = (snapshot.value as dynamic)["vehicle_details"]['car_model'];
    fullName = (snapshot.value as dynamic)['fullname'];
    vehicleNumber = (snapshot.value as dynamic)["vehicle_details"]['vehicle_number'];
  }
}
