import 'package:cab_driver/constants/brand_colors.dart';
import 'package:cab_driver/global_variables.dart';
import 'package:cab_driver/screens/main_page.dart';
import 'package:cab_driver/widgets/progress_dialog_cust.dart';
import 'package:cab_driver/widgets/taxi_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class VehicleInfo extends StatefulWidget {
  static const String id = 'vehicle-info';

  const VehicleInfo({Key? key}) : super(key: key);

  @override
  _VehicleInfoState createState() => _VehicleInfoState();
}

class _VehicleInfoState extends State<VehicleInfo> {
  final GlobalKey<ScaffoldState> _scffoldkey = GlobalKey<ScaffoldState>();

  TextEditingController _carModelController = TextEditingController();
  TextEditingController _carColorController = TextEditingController();
  TextEditingController _vehicleNumberController = TextEditingController();
  FocusNode _carModelFocusNode = FocusNode();
  FocusNode _carColorFocusNode = FocusNode();
  FocusNode _vehicleNumberFocusNode = FocusNode();
  FocusNode _nextFocusNode = FocusNode();

  void udpdateProfile() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return ProgressDialogCust(
            status: 'Loading.. ....',
          );
        });
    String id = currentFirebaseUser!.uid;
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference().child(
              'drivers/$id/vehicle_details',
            );
    Map map = {
      'car_color': _carModelController.text.trim(),
      'car_model': _carModelController.text.trim(),
      'vehicle_number': _vehicleNumberController.text.trim(),
    };
    databaseReference.set(map);
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
      Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scffoldkey,
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
          ),
          Image.asset(
            'assets/images/logo.png',
            height: 110,
            width: 110,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
            child: Column(
              children: [
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  'Enter vehicle details',
                  style: TextStyle(fontSize: 22.0, fontFamily: 'Brand-Bold'),
                ),
                SizedBox(
                  height: 25.0,
                ),

                //car model

                TextField(
                  controller: _carModelController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Car model',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10.0,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),

                //car color
                SizedBox(
                  height: 10.0,
                ),
                TextField(
                  controller: _carColorController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Car color',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10.0,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),

                //car number
                SizedBox(
                  height: 10.0,
                ),
                TextField(
                  maxLength: 11,
                  controller: _vehicleNumberController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Vehicle number',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10.0,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),

                SizedBox(
                  height: 40.0,
                ),
                TexiButton(
                  callback: () async {
                    var connectivityResult =
                        await (Connectivity().checkConnectivity());
                    if (connectivityResult != ConnectivityResult.mobile &&
                        connectivityResult != ConnectivityResult.wifi) {
                      showSnackBar(
                        'No Internet connection',
                      );
                      return;
                    }
                    if (_carModelController.text.trim().length < 3) {
                      showSnackBar('Please Provider a valid car model');
                      return;
                    }
                    if (_carColorController.text.trim().length < 3) {
                      showSnackBar('Please provide a valid car color');
                      return;
                    }
                    if (_vehicleNumberController.text.trim().length < 3) {
                      showSnackBar('Please Provide a valid vehicle number');
                      return;
                    }
                    print(currentFirebaseUser!.uid);
                    udpdateProfile();
                  },
                  color: BrandColors.colorAccentPurple,
                  title: 'PROCEED',
                )
              ],
            ),
          )
        ],
      ))),
    );
  }

  void showSnackBar(String title) {
    final snackBar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15.0),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
