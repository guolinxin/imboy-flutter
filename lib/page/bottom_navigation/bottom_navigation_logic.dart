import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:imboy/component/helper/sqflite.dart';
import 'package:imboy/store/repository/new_friend_repo_sqlite.dart';
import 'package:imboy/store/repository/user_repo_local.dart';

import 'bottom_navigation_state.dart';

class BottomNavigationLogic extends GetxController {
  final state = BottomNavigationState();

  // 新的好友提醒计数器
  RxSet newFriendRemindCounter = <String>{}.obs;

  /// 重新计算 新的好友提醒计数器
  Future<void> countNewFriendRemindCounter() async {
    List<Map<String, dynamic>> items = await Sqlite.instance.query(
      NewFriendRepo.tablename,
      columns: [
        NewFriendRepo.from,
      ],
      // 0 待验证  1 已添加  2 已过期
      where: '${NewFriendRepo.status}=? and ${NewFriendRepo.to}=?',
      whereArgs: [0, UserRepoLocal.to.currentUid],
      orderBy: "create_time desc",
      limit: 1000,
    );
    debugPrint(
        ">>> on countNewFriendRemindCounter1 ${newFriendRemindCounter.toString()}");
    debugPrint(">>> on countNewFriendRemindCounter2 ${items.toString()}");
    newFriendRemindCounter = <String>{}.obs;
    if (items.isNotEmpty) {
      for (Map<String, dynamic> e in items) {
        String from = e[NewFriendRepo.from] ?? "";
        newFriendRemindCounter.add(from);
      }
    }
    update([newFriendRemindCounter]);
    debugPrint(
        ">>> on countNewFriendRemindCounter3 ${newFriendRemindCounter.toString()}");
  }

  //改变底部导航栏索引
  void changeBottomBarIndex(int index) {
    state.bottombarIndex.value = index;
    // print(state.bottombarIndex.value);
  }
}
