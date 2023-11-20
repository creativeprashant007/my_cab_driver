import 'package:cab_driver/constants/brand_colors.dart';
import 'package:cab_driver/provider/data_provider.dart';
import 'package:cab_driver/widgets/brand_divider.dart';
import 'package:cab_driver/widgets/history_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trip History"),
        backgroundColor: BrandColors.colorPrimary,
      ),
      body: ListView.separated(
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.all(0),
          itemBuilder: (context, index) {
            return HistoryTile(
              history: Provider.of<AppData>(context, listen: false)
                  .tripHistory[index],
            );
          },
          separatorBuilder: (_, __) => BrandDivider(),
          itemCount:
              Provider.of<AppData>(context, listen: false).tripHistory.length),
    );
  }
}
