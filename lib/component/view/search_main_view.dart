import 'package:flutter/material.dart';
import 'package:imboy/config/const.dart';

class SearchMainView extends StatelessWidget {
  final GestureTapCallback? onTap;
  final String? text;
  final bool? isBorder;

  SearchMainView({
    this.onTap,
    this.text,
    this.isBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    var row = new Row(
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: new Icon(Icons.search, color: AppColors.MainTextColor),
        ),
        new Text(
          text!,
          style: TextStyle(color: AppColors.MainTextColor),
        )
      ],
    );

    return new InkWell(
      child: new Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: isBorder!
              ? Border(
                  bottom: BorderSide(color: AppColors.LineColor, width: 0.2),
                )
              : null,
        ),
        padding: EdgeInsets.symmetric(vertical: 15.0),
        child: row,
      ),
      onTap: onTap ?? () {},
    );
  }
}
