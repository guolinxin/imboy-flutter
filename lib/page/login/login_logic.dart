import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:imboy/config/const.dart';
import 'package:imboy/helper/extension/get_extension.dart';
import 'package:imboy/helper/func.dart';
import 'package:imboy/helper/http/http_client.dart';
import 'package:imboy/helper/http/http_response.dart';
import 'package:imboy/page/bottom_navigation/bottom_navigation_view.dart';
import 'package:imboy/store/repository/user_repo_sp.dart';

import 'login_state.dart';

class LoginLogic extends GetxController {
  final state = LoginState();
  late String _username;
  String _password = "";
  bool passwordVisible = false; //设置初始状态

  void visibilityOnOff() {
    if (passwordVisible) {
      passwordVisible = false;
    } else {
      passwordVisible = true;
    }
    update();
  }

  void onUsernameChanged(String username) {
    _username = username.trim();
  }

  void onPasswordChanged(String password) {
    _password = password.trim();
  }

  submit() async {
    if (strEmpty(_password)) {
      onPasswordChanged("admin888");
    }
    if (strEmpty(_username.trim())) {
      Get.snackbar('Hi', '登录账号不能为空');
      return;
    }

    if (strEmpty(_password.trim())) {
      Get.snackbar('Hi', '登录密码不能为空');
      return;
    }

    // Get.loading();
    bool loginSuccess = await login(_username.trim(), _password.trim());
    Get.dismiss();
    if (loginSuccess) {
      Get.off(() => BottomNavigationPage());
    }
  }

  Future<bool> login(String account, String password) async {
    try {
      HttpResponse resp1 = await HttpClient.client.get("/init");
      if (!resp1.ok) {
        String msg = '网络故障或服务故障';
        msg += resp1.error!.code.toString() + "; msg: " + resp1.error!.message;
        Get.snackbar('提示', msg);
        return false;
      }
      debugPrint(">>>>> on {resp1.payload}");
      debugPrint(">>>>> on {resp1}");
      String pubKey = resp1.payload['login_rsa_pub_key'];
      final rsaEncrypt = resp1.payload['login_pwd_rsa_encrypt'];
      if (rsaEncrypt == "1") {
        dynamic publicKey = RSAKeyParser().parse(pubKey);
        final encrypter = Encrypter(RSA(publicKey: publicKey));
        final encrypted = encrypter.encrypt(password);

        password = encrypted.base64.toString();
      }
      HttpResponse resp2 = await HttpClient.client.post(
        API.login,
        data: {
          "account": account,
          "pwd": password,
          "rsa_encrypt": rsaEncrypt,
        },
        options: Options(
          contentType: "application/x-www-form-urlencoded",
        ),
      );
      if (!resp2.ok) {
        Get.snackbar('Hi', resp2.error!.message,
            duration: Duration(seconds: 5));
        return false;
      } else {
        debugPrint(">>>>> on user logoin success {$resp2.toString()}");
        return await (UserRepoSP()).loginAfter(resp2.payload);
      }
    } on PlatformException {
      Get.snackbar('', '你已登录或者其他错误');
      return false;
    }
  }
}
