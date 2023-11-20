import 'package:cab_driver/constants/brand_colors.dart';
import 'package:cab_driver/helpers/helper_methods.dart';
import 'package:cab_driver/widgets/brand_divider.dart';
import 'package:cab_driver/widgets/taxi_button.dart';
import 'package:flutter/material.dart';

class CollectPayment extends StatelessWidget {
  CollectPayment({Key? key, required this.paymentMethod, required this.fares})
      : super(key: key);
  final String paymentMethod;
  final int fares;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            Text("${paymentMethod.toUpperCase()} PAYMENT"),
            SizedBox(
              height: 20,
            ),
            BrandDivider(),
            SizedBox(
              height: 16.0,
            ),
            Text(
              "RS $fares",
              style: TextStyle(
                fontFamily: "Brand-Bold",
                fontSize: 50,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Amount above is the total fares to be charged to the rider",
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              width: 230,
              child: TexiButton(
                title: (paymentMethod == "cash") ? "COLLECT CASH" : "CONFIRM",
                color: BrandColors.colorGreen,
                callback: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  HelperMethods.enableHomTabLocationUpdates();
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
