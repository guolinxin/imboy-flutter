import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContactModel extends ISuspensionBean {
  ContactModel({
    this.uid,
    this.account,
    required this.nickname,
    this.avatar,
    this.status,
    this.remark,
    this.area,
    this.sign,
    this.updateTime,
    this.isFriend,
    this.nameIndex,
    this.namePinyin,
    this.bgColor,
    this.iconData,
    this.firstletter,
  });

  final String? uid; // 用户ID
  final String? account; // 用户ID
  final String nickname; // 备注 or 昵称
  final String? avatar; // 用户头像
  final String? status; // offline | online |
  final String? remark;
  final String? area;
  final String? sign;
  final int? updateTime;
  int? isFriend;

  String? nameIndex;
  String? namePinyin;
  Color? bgColor;
  IconData? iconData;
  String? firstletter;

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return new ContactModel(
      uid: json["id"] ?? (json["uid"] ?? ""),
      account: json["account"].toString(),
      nickname: json["nickname"].toString(),
      avatar: json["avatar"].toString(),
      status: json["status"]?.toString(),
      remark: json["remark"]?.toString(),
      area: json["area"]?.toString(),
      sign: json["sign"]?.toString(),
      // 单位毫秒，13位时间戳  1561021145560
      updateTime: json["update_time"] ?? DateTime.now().millisecondsSinceEpoch,
      isFriend: json["is_friend"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': uid,
        'account': account,
        'nickname': nickname,
        'avatar': avatar,
        'status': status,
        'remark': remark,
        'area': area,
        'sign': sign,
        'update_time': updateTime,
        'is_friend': isFriend,
        //
        'firstletter': firstletter,
        'nameIndex': nameIndex,
        'namePinyin': namePinyin
      };

  @override
  String getSuspensionTag() => nameIndex!;

  @override
  String toString() => json.encode(this);
}
