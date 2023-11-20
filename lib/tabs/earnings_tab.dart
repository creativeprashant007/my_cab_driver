import 'package:cab_driver/constants/brand_colors.dart';
import 'package:cab_driver/provider/data_provider.dart';
import 'package:cab_driver/screens/history_page.dart';
import 'package:cab_driver/widgets/brand_divider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EarningTab extends StatelessWidget {
  EarningTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          child: Column(
        children: [
          Container(
            color: BrandColors.colorPrimary,
            padding: EdgeInsets.symmetric(vertical: 70),
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  "Total Earnings",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "Rs ${Provider.of<AppData>(context, listen: false).earnings}",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontFamily: "Brand-Bold"),
                ),
              ],
            ),
          ),
          trips(context),
          BrandDivider(),
        ],
      )),
    );
  }

  TextButton trips(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HistoryPage()));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 30),
        child: Row(
          children: [
            Image.asset(
              "assets/images/taxi.png",
              height: 70,
              width: 70,
            ),
            SizedBox(
              width: 16,
            ),
            Text(
              "Trips",
              style: TextStyle(fontSize: 15),
            ),
            Expanded(
              child: Container(
                child: Text(
                  "${Provider.of<AppData>(context, listen: false).tripCount}",
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
