import 'package:firebase_database/firebase_database.dart';

class History {
  String? pickup;
  String? destination;
  String? fares;
  String? status;
  String? createdAt;
  String? paymentMethod;

  History({
    this.pickup,
    this.destination,
    this.fares,
    this.status,
    this.paymentMethod,
    this.createdAt,
  });

  History.fromSnapShot(DataSnapshot snapshot) {
    pickup = (snapshot.value as dynamic)['pickup_address'];
    destination = (snapshot.value as dynamic)['destination_address'];
    fares = (snapshot.value as dynamic)['fares'].toString();
    status = (snapshot.value as dynamic)['status'];
    paymentMethod = (snapshot.value as dynamic)['payment_method'];
    createdAt = (snapshot.value as dynamic)['created_at'];
  }
}
