import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:imboy/component/view/controller.dart';
import 'package:imboy/config/init.dart';
import 'package:imboy/helper/log.dart';
import 'package:imboy/page/bottom_navigation/bottom_navigation_view.dart';
import 'package:imboy/page/login/login_view.dart';
import 'package:imboy/page/pages.dart';
import 'package:imboy/store/repository/user_repo_local.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'helper/locales.dart';
import 'helper/locales.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  // 要读取系统语言，可以使用window.locale
  String? local = Intl.shortLocale(ui.window.locale.toString());
  debugPrint(">>> on main ${local}");
  // zh_Hans_CN ui.window.locale.toString();
  await Jiffy.locale(local);
  // runApp(IMBoyApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(IMBoyApp()));
}

class IMBoyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      builder: () => RefreshConfiguration(
        headerBuilder: () => ClassicHeader(),
        footerBuilder: () => ClassicFooter(),
        hideFooterWhenNotFull: true,
        headerTriggerDistance: 80,
        maxOverScrollExtent: 100,
        footerTriggerDistance: 150,
        child: GetMaterialApp(
          title: 'IMBoy',
          // 底部导航组件
          home: UserRepoLocal.to.isLogin ? BottomNavigationPage() : LoginPage(),
          debugShowCheckedModeBanner: false,
          getPages: AppPages.routes,
          // initialRoute: AppPages.INITIAL,
          // translations: TranslationService(),
          navigatorObservers: [AppPages.observer],
          // localizationsDelegates: [
          //   GlobalMaterialLocalizations.delegate,
          //   GlobalWidgetsLocalizations.delegate,
          //   GlobalCupertinoLocalizations.delegate,
          // ],
          translationsKeys: AppTranslation.translations,

          translations: IMBoyTranslations(), // 你的翻译
          locale: Locale('zh', 'CN'), // 将会按照此处指定的语言翻译
          fallbackLocale: Locale('en', 'US'), // 添加一个回调语言选项，以备上面指定的语言翻译不存在
          defaultTransition: Transition.fade,
          opaqueRoute: Get.isOpaqueRouteDefault,
          popGesture: Get.isPopGestureEnable,
          theme: Get.find<ThemeController>().darkMode == 0
              ? ThemeData.light()
              : ThemeData.dark(),
          enableLog: true,
          logWriterCallback: Logger.write,
        ),
      ),
    );
  }
}
