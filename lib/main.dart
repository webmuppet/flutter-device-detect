import 'dart:io' show Platform;

import 'package:flutter/foundation.dart'; // Needed for kIsWeb
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:disk_space/disk_space.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  double? _totalSpace;
  double? _freeSpace;

  @override
  void initState() {
    super.initState();
    _initDeviceInfo();
  }

  Future<void> _initDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    var deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        var webBrowserInfo = await deviceInfoPlugin.webBrowserInfo;
        if (_isMobileBrowser(webBrowserInfo.userAgent)) {
          if (Platform.isAndroid) {
            deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
          } else if (Platform.isIOS) {
            deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
          }
        } else {
          deviceData = _readWebBrowserInfo(webBrowserInfo);
        }
      } else if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } catch (e) {
      deviceData = {'Error:': 'Failed to get device info'};
    }

    try {
      _totalSpace = await DiskSpace.getTotalDiskSpace;
      _freeSpace = await DiskSpace.getFreeDiskSpace;
    } catch (e) {
      // Handle exception if disk space information is not available
    }

    setState(() {
      _deviceData = deviceData;
    });
  }

  bool _isMobileBrowser(String? userAgent) {
    if (userAgent == null) return false;
    return userAgent.contains('Mobi');
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': data.browserName.name,
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'serialNumber': build.serialNumber,
      'isLowRamDevice': build.isLowRamDevice,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Device Info'),
        ),
        body: _buildNormalContainers(),
      ),
    );
  }

  Widget _buildNormalContainers() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: _buildDeviceInfoWidgets(),
      ),
    );
  }

  List<Widget> _buildDeviceInfoWidgets() {
    return _deviceData.keys.map((String property) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Wrap(
          children: <Widget>[
            Text(
              property,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Text(
              '${_deviceData[property]}',
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      );
    }).toList()
      ..add(Padding(
        padding: const EdgeInsets.all(10.0),
        child: Wrap(
          children: <Widget>[
            Text(
              'Total Disk Space',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Text(
              _totalSpace != null
                  ? '${_totalSpace! / 1024} GB'
                  : 'Unavailable',
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ))
      ..add(Padding(
        padding: const EdgeInsets.all(10.0),
        child: Wrap(
          children: <Widget>[
            Text(
              'Free Disk Space',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Text(
              _freeSpace != null
                  ? '${_freeSpace! / 1024} GB'
                  : 'Unavailable',
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ));
  }
}
