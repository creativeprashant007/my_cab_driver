import 'package:cab_driver/constants/brand_colors.dart';
import 'package:cab_driver/model/history.dart';

import 'package:flutter/material.dart';

class HistoryTile extends StatelessWidget {
  final History? history;
  HistoryTile({this.history});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/pickicon.png',
                      height: 16,
                      width: 16,
                    ),
                    SizedBox(
                      width: 18,
                    ),
                    Expanded(
                        child: Container(
                            child: Text(
                      history!.pickup!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15),
                    ))),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Rs. ${history!.fares!}',
                      style: TextStyle(
                          fontFamily: 'Brand-Bold',
                          fontSize: 12,
                          color: BrandColors.colorPrimary),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Image.asset(
                    'assets/images/desticon.png',
                    height: 16,
                    width: 16,
                  ),
                  SizedBox(
                    width: 18,
                  ),
                  Text(
                    history!.destination!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                history!.createdAt!,
                style: TextStyle(color: BrandColors.colorTextLight),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
