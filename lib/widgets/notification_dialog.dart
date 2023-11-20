import 'package:cab_driver/constants/brand_colors.dart';
import 'package:cab_driver/global_variables.dart';
import 'package:cab_driver/helpers/helper_methods.dart';
import 'package:cab_driver/model/trip_detail_model.dart';
import 'package:cab_driver/screens/new_trip_page.dart';
import 'package:cab_driver/widgets/TaxiOutlineButton.dart';
import 'package:cab_driver/widgets/brand_divider.dart';
import 'package:cab_driver/widgets/progress_dialog_cust.dart';
import 'package:cab_driver/widgets/taxi_button.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationDialog extends StatelessWidget {
  final TripDetail tripDetail;
  const NotificationDialog({
    Key? key,
    required this.tripDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30.0,
            ),
            Image.asset('assets/images/taxi.png'),
            SizedBox(
              height: 16.0,
            ),
            Text(
              'NEW TRIP REQUEST',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Brand-Bold',
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Image.asset(
                          'assets/images/pickicon.png',
                          height: 18,
                          width: 18,
                        ),
                      ),
                      SizedBox(
                        width: 18.0,
                      ),
                      Expanded(
                        child: Text(
                          '${tripDetail.pickupAddress}',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Image.asset(
                          'assets/images/desticon.png',
                          height: 18,
                          width: 18,
                        ),
                      ),
                      SizedBox(
                        width: 18.0,
                      ),
                      Expanded(
                        child: Text(
                          '${tripDetail.destinationAddress}',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            BrandDivider(),
            SizedBox(
              width: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: TaxiOutlineButton(
                        title: 'DECLINE',
                        onPressed: () {
                          assetAudioPlayer.stop();

                          Navigator.of(context).pop();
                        },
                        color: BrandColors.colorPrimary,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Container(
                      child: TexiButton(
                        title: 'ACCEPT',
                        callback: () {
                          assetAudioPlayer.dispose();
                          assetAudioPlayer.pause();
                          assetAudioPlayer.stop();
                          assetAudioPlayer.stop();
                          checkAvailability(context);
                        },
                        color: BrandColors.colorGreen,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void checkAvailability(context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return ProgressDialogCust(
            status: 'Fetching Details...',
          );
        });
    DatabaseReference newRideRef = FirebaseDatabase.instance
        .ref()
        .child('drivers/${currentFirebaseUser!.uid}/newtrip');

    newRideRef.once().then((DatabaseEvent snapshot) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      String thisRideID = '';
      print("accetp snapsot ${snapshot.snapshot.value}");
      if (snapshot.snapshot.value != null) {
        thisRideID = snapshot.snapshot.value.toString();
      } else {
        Fluttertoast.showToast(
            msg: "Ride not found",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      if (thisRideID == tripDetail.rideId) {
        newRideRef.set('accepted');
        HelperMethods.disableHomTabLocationUpdate();
        print('ride has been accepted');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NewTripPage(
              tripDetail: tripDetail,
            ),
          ),
        );
      } else if (thisRideID == 'cancelled') {
        print('this ride has been cancelled by user');
        Fluttertoast.showToast(
            msg: "Ride Has been cancell by user",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (thisRideID == 'timeout') {
        print('this ride has been time out');
        Fluttertoast.showToast(
            msg: "Ride Has been time out",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Ride not found",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }
}
