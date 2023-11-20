import 'package:cab_driver/constants/brand_colors.dart';
import 'package:flutter/material.dart';

class TaxiOutlineButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color color;

  TaxiOutlineButton({
    required this.title,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.resolveWith((states) => color),
            shape: MaterialStateProperty.resolveWith(
                (states) => RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ))),
        onPressed: onPressed,
        child: Container(
          height: 50.0,
          child: Center(
            child: Text(title,
                style: TextStyle(
                  fontSize: 15.0,
                  fontFamily: 'Brand-Bold',
                  color: BrandColors.colorText,
                )),
          ),
        ));
  }
}
