import 'package:cab_driver/constants/brand_colors.dart';
import 'package:cab_driver/widgets/TaxiOutlineButton.dart';
import 'package:cab_driver/widgets/taxi_button.dart';
import 'package:flutter/material.dart';

class ConfirmSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function onPress;

  const ConfirmSheet(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15.0,
            spreadRadius: 0.5,
            offset: Offset(
              0.7,
              0.7,
            ),
          ),
        ],
      ),
      height: 220,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 18,
        ),
        child: Column(
          children: [
            Text(
              '$title',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Brand-Bold',
                color: BrandColors.colorText,
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Text(
              // 'You are about to become available to receive trip requests',
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: BrandColors.colorText,
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    child: TaxiOutlineButton(
                      title: 'BACK',
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      color: BrandColors.colorLightGrayFair,
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Container(
                    child: TexiButton(
                      callback: () {
                        onPress();
                      },
                      title: 'CONFIRM',
                      color: title == 'GO ONLINE'
                          ? BrandColors.colorGreen
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
