import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';

class DeviceExt extends DeviceInfoPlugin {
  static DeviceExt get to => Get.find();

  static Future<String> get did async {
    Map<String, dynamic>? info = await to.detail;
    return info!["did"];
  }

  Future<Map<String, dynamic>?> get detail async {
    if (Platform.isAndroid) {
      var data = await androidInfo;
      return {
        "cos": "android",
        "did": data.id,
        "deviceName": data.model,
        "deviceVersion": json.encode({
          'version.securityPatch': data.version.securityPatch,
          'version.sdkInt': data.version.sdkInt,
          'version.release': data.version.release,
          'version.previewSdkInt': data.version.previewSdkInt,
          'version.incremental': data.version.incremental,
          'version.codename': data.version.codename,
          'version.baseOS': data.version.baseOS,
        }),
        "more": json.encode({
          'board': data.board,
          'bootloader': data.bootloader,
          'brand': data.brand,
          'device': data.device,
          'display': data.display,
          'fingerprint': data.fingerprint,
          'hardware': data.hardware,
          'host': data.host,
          'id': data.id,
          'manufacturer': data.manufacturer,
          'model': data.model,
          'product': data.product,
          'supported32BitAbis': data.supported32BitAbis,
          'supported64BitAbis': data.supported64BitAbis,
          'supportedAbis': data.supportedAbis,
          'tags': data.tags,
          'type': data.type,
          'isPhysicalDevice': data.isPhysicalDevice,
          'systemFeatures': data.systemFeatures,
          'displaySizeInches':
              ((data.displayMetrics.sizeInches * 10).roundToDouble() / 10),
          'displayWidthPixels': data.displayMetrics.widthPx,
          'displayWidthInches': data.displayMetrics.widthInches,
          'displayHeightPixels': data.displayMetrics.heightPx,
          'displayHeightInches': data.displayMetrics.heightInches,
          'displayXDpi': data.displayMetrics.xDpi,
          'displayYDpi': data.displayMetrics.yDpi,
        }),
      };

      //UUID for Android
    } else if (Platform.isIOS) {
      var data = await iosInfo;
      return {
        "cos": "ios",
        "did": data.identifierForVendor,
        "deviceName": data.name,
        "deviceVersion": data.systemVersion,
        "more": json.encode({
          'model': data.model,
          'localizedModel': data.localizedModel,
          'identifierForVendor': data.identifierForVendor,
          'isPhysicalDevice': data.isPhysicalDevice,
          'utsname.sysname:': data.utsname.sysname,
          'utsname.nodename:': data.utsname.nodename,
          'utsname.release:': data.utsname.release,
          'utsname.version:': data.utsname.version,
          'utsname.machine:': data.utsname.machine,
        }),
      };
    } else if (Platform.isMacOS) {
      var data = await macOsInfo;
      return {
        "cos": "macOs",
        "did": data.systemGUID,
        "deviceName": data.model,
        "deviceVersion": data.kernelVersion,
        "more": json.encode({
          'computerName': data.computerName,
          'hostName': data.hostName,
          'arch': data.arch,
          'kernelVersion': data.kernelVersion,
          'osRelease': data.osRelease,
          'activeCPUs': data.activeCPUs,
          'memorySize': data.memorySize,
          'cpuFrequency': data.cpuFrequency,
          'systemGUID': data.systemGUID,
        }),
      };
    } else if (Platform.isLinux) {
      var data = await linuxInfo;
      return {
        "cos": "linux",
        "did": data.id,
        "deviceName": data.name,
        "deviceVersion": data.version,
        "more": json.encode({
          'idLike': data.idLike,
          'versionCodename': data.versionCodename,
          'versionId': data.versionId,
          'prettyName': data.prettyName,
          'buildId': data.buildId,
          'variant': data.variant,
          'variantId': data.variantId,
          'machineId': data.machineId,
        }),
      };
    }
    return null;
  }
}
